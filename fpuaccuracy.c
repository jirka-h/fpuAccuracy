/*
Copyright 2018 by Jirka Hladky <hladky DOT jiri AT gmail DOT com>
Based on tools by Scott Duplichan from http://notabs.org/fpuaccuracy/
Compile with GCC with
gcc -O3 -Wall -Wextra -o fpuaccuracy fpuaccuracy.c -lmpfr -lm
*/

//----------------------------------------------------------------------------
//
// copyright 2013 Scott Duplichan
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
//----------------------------------------------------------------------------
// Pentium Processor Family Developer’s Manual Volume 3: Architecture and Programming Manual 1995
//     ftp://download.intel.com/design/pentium/manuals/24143004.pdf
//
// Intel Architecture Software Developer’s Manual Volume 1: Basic Architecture 1999
//     http://download.intel.com/support/processors/pentiumii/sb/24319002.pdf
//

//#include <windows.h>
#include <time.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <math.h>
#include <float.h>
#include <mpfr.h>

/*
 * See following documentation
 * https://en.wikipedia.org/wiki/X86_instruction_listings#Original_8087_instructions
 * https://www.felixcloutier.com/x86/fsin
 * https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html
 */ 

inline void x87_80bit_sin (long double *x, long double *y) {
  asm ("fsin" :"=t" (*y) : "0" (*x));
}
inline void x87_80bit_cos (long double *x, long double *y) {
  asm ("fcos" :"=t" (*y) : "0" (*x));
}
//Replace ST(0) with its approximate tangent and push 1 onto the FPU stack.
inline void x87_80bit_tan (long double *x, long double *y) {
  long double unused;
  asm ("fptan" :"=t" (unused), "=u" (*y) : "0" (*x) );
}
//Replace ST(1) with arctan(ST(1)/ST(0)) and pop the register stack.
inline void x87_80bit_atan (long double *x, long double *y) {
  asm ("fpatan" :"=t" (*y) : "0" (1.0), "u" (*x) : "st(1)");
}
//computes 2^x-1
inline void x87_80bit_f2xm1 (long double *x, long double *y) {
  asm ("f2xm1" :"=t" (*y) : "0" (*x));
}
// computes y * log_2(x) - Replace ST(1) with (ST(1) * log2ST(0)) and pop the register stack.
inline void x87_80bit_fyl2x (long double *x, long double *y) {
  asm ("fyl2x" : "=t" (*y) : "0" (*x), "u" (1.0) : "st(1)");
}
//computes y * log_2( x +1 )
inline void x87_80bit_fyl2xp1 (long double *x, long double *y) {
//This asm takes two inputs, which are popped by the fyl2xp1 opcode, and replaces them with one output. The st(1) clobber is necessary for the compiler to know that fyl2xp1 pops both inputs.
  asm ("fyl2xp1" : "=t" (*y) : "0" (*x), "u" (1.0) : "st(1)");
}

typedef enum
    {
    INC_LINEAR,
    INC_LOG   ,
    INC_ULP   ,
    }
INC_TYPE;

// ULP_BITS - number of extended precision bits used for ULP calculation
#define ULP_BITS 256

// EP_BITS - number of extended precision bits used for > long double precision
#define EP_BITS 256

// ADDSUB_BITS - number of extended precision bits used to add or sub big/small long double
#define ADDSUB_BITS 32768

//----------------------------------------------------------------------------
//
// lfsr64gpr - left shift galois type lfsr for 64-bit data, general purpose register implementation
//
static uint64_t lfsr64gpr (uint64_t data, uint64_t mask)
   {
   uint64_t carryOut = data >> 63;
   uint64_t maskOrZ = -carryOut; 
   return (data << 1) ^ (maskOrZ & mask);
   }

//----------------------------------------------------------------------------
//
// formatMessage - return formatted message in static buffer
//
char *formatMessage (char *format, ...)
   {
   #define DIMENSION(array) (sizeof (array) / sizeof (array [0]))
   va_list marker;
   static char buffer [8][200];
   static int cycle;
   char *position = buffer [cycle];
   cycle++;
   if (cycle == DIMENSION (buffer)) cycle = 0;

   va_start (marker, format);
   vsprintf (position, format, marker);
   va_end (marker);
   return position;
   }

//-----------------------------------------------------------------------------
//
// format a number as decimal ascii with commas every 3 digits
//

char *commanumber (uint64_t value)
   {
   #define MAXCOLUMNS 28
   int digit = 0;
   char outbuf [MAXCOLUMNS];
   char buffer [MAXCOLUMNS];
   char *input = buffer + MAXCOLUMNS - 2;
   char *output = outbuf + MAXCOLUMNS - 2;

   outbuf [MAXCOLUMNS - 1] = '\0';
   sprintf (buffer, "%*"PRId64"", MAXCOLUMNS - 1, value);

   for (;;)
      {
      *output = *input;
      digit++;
      input--;
      output--;
      if (*input == ' ') break;
      if (digit % 3 == 0)
         {
         *output = ',';
         output--;
         }
      }

   return formatMessage (output + 1);
   }

double timeit (void) {
  struct timespec now;
  clock_gettime(CLOCK_MONOTONIC, &now);
  return now.tv_sec + now.tv_nsec / 1000000000.0;
}

static char *hexDump (void *data, int size)
    {
    int words = size / 2;
    char *position;
    char buffer [64];
    int index;
    uint16_t *array16;
    
    array16 = data;
    position = buffer;

    for (index = words - 1; index >= 0; index--)
        {
        if (index != words - 1) position += sprintf (position, " ");
        position += sprintf (position, "%04X", array16 [index]);
        }
    return formatMessage (buffer);
    }

//----------------------------------------------------------------------------
// decimalLongDouble - format long double as decimal

static char *decimalLongDouble (long double value)
    {
    mpfr_t mpfr_value;
    char buffer [64];

    mpfr_init2 (mpfr_value, 64); // 64 is precision of long double for gcc-x86
    mpfr_set_ld (mpfr_value, value, MPFR_RNDN);
    mpfr_snprintf (buffer, sizeof buffer - 1, "%.*RG", LDBL_DIG + 2, mpfr_value);
    mpfr_clear (mpfr_value);
    return formatMessage ("%s", buffer);
    }

//----------------------------------------------------------------------------
// hexWithLongDouble - format long double as hex followed by decimal

static char *hexWithLongDouble (long double value)
    {
    return formatMessage ("%s   (decimal %s)", hexDump (&value, 10), decimalLongDouble (value));
    }

//----------------------------------------------------------------------------
// mpfr_scale_2ui - wrapper to combine MPFR functions mpfr_mul_2ui and mpfr_div_2ui

static int mpfr_scale_2ui (mpfr_t rop, mpfr_t op1, long int op2, mpfr_rnd_t rnd)
    {
    if (op2 >= 0) return mpfr_mul_2ui (rop, op1, op2, rnd);
    else return mpfr_div_2ui (rop, op1, -op2, rnd);
    }

//----------------------------------------------------------------------------
// return ulp value of difference, using the Intel definition of ulp:
// error = (f(x) - F(x)) / 2^(k-63)

static long double ulpDiff (mpfr_t mpfr_correct, long double computed)
    {
    mpfr_t mpfr_diff, mpfr_computed, mpfr_temp;
    long double result;
    long k;

    mpfr_init2 (mpfr_diff, ULP_BITS);
    mpfr_init2 (mpfr_computed, ULP_BITS);
    mpfr_init2 (mpfr_temp, ULP_BITS);

    mpfr_set_ld (mpfr_computed, computed, MPFR_RNDN);
    mpfr_sub (mpfr_diff, mpfr_computed, mpfr_correct, MPFR_RNDN);
    mpfr_get_d_2exp (&k, mpfr_correct, MPFR_RNDN);
    k--;

    // for proper handling of denormals
    if (k < -16382) k = -16382;

    mpfr_scale_2ui (mpfr_temp, mpfr_diff, 63 - k, MPFR_RNDN);
    result = mpfr_get_ld (mpfr_temp, MPFR_RNDN);

    mpfr_clear (mpfr_diff);
    mpfr_clear (mpfr_computed);
    mpfr_clear (mpfr_temp);
    return result;
    }

//----------------------------------------------------------------------------
// printResult - print result of an x87 fpu test case

static void printResult (long double arg, long double actual, long double fpu, long double ulp, FILE *logfile, char *comment)
    {
    fprintf (logfile, "%s\n", comment);
    fprintf (logfile, "argument   %s\n", hexWithLongDouble (arg));
    fprintf (logfile, "actual     %s\n", hexWithLongDouble (actual));
    fprintf (logfile, "x87 fpu    %s\n", hexWithLongDouble (fpu));
    fprintf (logfile, "error      %s ulp\n\n", decimalLongDouble (ulp));
    }

//----------------------------------------------------------------------------
// sinTest - test x87 fpu fsin instruction

long double sinTest (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, EP_BITS);
    mpfr_init2 (mpfr_actual, EP_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_sin (mpfr_actual, mpfr_arg, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_sin (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------
// cosTest - test x87 fpu fcos instruction

long double cosTest (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, EP_BITS);
    mpfr_init2 (mpfr_actual, EP_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_cos (mpfr_actual, mpfr_arg, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_cos (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------
// tanTest - test x87 fpu fptan instruction

long double tanTest (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, EP_BITS);
    mpfr_init2 (mpfr_actual, EP_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_tan (mpfr_actual, mpfr_arg, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_tan (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------
// atanTest - test x87 fpu fpatan instruction

long double atanTest (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, EP_BITS);
    mpfr_init2 (mpfr_actual, EP_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_atan (mpfr_actual, mpfr_arg, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_atan (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------
// f2xm1Test - test x87 fpu f2xm1 instruction

long double f2xm1Test (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, ADDSUB_BITS);
    mpfr_init2 (mpfr_actual, ADDSUB_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_exp2 (mpfr_actual, mpfr_arg, MPFR_RNDN);
    mpfr_sub_si (mpfr_actual, mpfr_actual, 1, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_f2xm1 (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------
// fyl2xTest - test x87 fpu fyl2x instruction

long double fyl2xTest (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, EP_BITS);
    mpfr_init2 (mpfr_actual, EP_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_log2 (mpfr_actual, mpfr_arg, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_fyl2x (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------
// fyl2xp1Test - test x87 fpu fyl2xp1 instruction

long double fyl2xp1Test (long double arg, FILE *logfile, char *comment)
    {
    long double fpu, actual, ulp;
    mpfr_t mpfr_arg, mpfr_actual;

    mpfr_init2 (mpfr_arg, ADDSUB_BITS);
    mpfr_init2 (mpfr_actual, ADDSUB_BITS);
    mpfr_set_ld (mpfr_arg, arg, MPFR_RNDN);
    mpfr_add_ui (mpfr_arg, mpfr_arg, 1, MPFR_RNDN);
    mpfr_log2 (mpfr_actual, mpfr_arg, MPFR_RNDN);
    actual = mpfr_get_ld (mpfr_actual, MPFR_RNDN);
    x87_80bit_fyl2xp1 (&arg, &fpu);
    ulp = ulpDiff (mpfr_actual, fpu);
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_actual);
    if (comment) printResult (arg, actual, fpu, ulp, logfile, comment);
    return ulp;
    }

//----------------------------------------------------------------------------

static void ulpList (long double (*test) (long double arg, FILE *logfile, char *comment), long double start, long double end, long count, INC_TYPE incType, FILE *logfile, int logDetail)
    {
    mpfr_t mpfr_arg, mpfr_range, mpfr_explow, mpfr_expinc, mpfr_start, mpfr_inc, mpfr_end, mpfr_temp;
    long double arg, ulp, biggest;
    uint64_t pattern, mask;
    uint16_t *argptr16;
    uint64_t *argptr64;
    int index, ulpInc;
    char *comment = NULL;

    if (logDetail) comment = "";

    // lfsr init
    mask = 0xBEFFFFFFFFFFFFFF;
    pattern = 1;
    argptr16 = (void *) &arg;
    argptr64 = (void *) &arg;
    ulpInc = 0;

    mpfr_init2 (mpfr_arg, EP_BITS);
    mpfr_init2 (mpfr_range, EP_BITS);
    mpfr_init2 (mpfr_explow, EP_BITS);
    mpfr_init2 (mpfr_expinc, EP_BITS);
    mpfr_init2 (mpfr_start, EP_BITS);
    mpfr_init2 (mpfr_end, EP_BITS);
    mpfr_init2 (mpfr_inc, EP_BITS);
    mpfr_init2 (mpfr_temp, EP_BITS);

    mpfr_set_ld (mpfr_arg, start, MPFR_RNDN);
    biggest = 0;

    if (incType == INC_LINEAR)
        {
        mpfr_set_ld (mpfr_start, start, MPFR_RNDN);
        mpfr_set_ld (mpfr_end, end, MPFR_RNDN);
        mpfr_sub (mpfr_range, mpfr_end, mpfr_start, MPFR_RNDN);
        mpfr_div_si (mpfr_inc, mpfr_range, count, MPFR_RNDN);
        }
    else if (incType == INC_LOG)
        {
        mpfr_set_ld (mpfr_start, start, MPFR_RNDN);
        mpfr_set_ld (mpfr_end, end, MPFR_RNDN);
        mpfr_log2 (mpfr_explow, mpfr_start, MPFR_RNDN);
        mpfr_log2 (mpfr_expinc, mpfr_end, MPFR_RNDN);
        mpfr_sub (mpfr_expinc, mpfr_expinc, mpfr_explow, MPFR_RNDN);
        mpfr_div_si (mpfr_expinc, mpfr_expinc, count, MPFR_RNDN);
        }

    if (incType != INC_ULP)
        for (index = 0; index < count; index++)
            {
            arg = mpfr_get_ld (mpfr_arg, MPFR_RNDN);

            // randomize the least few arg bits to avoid aliasing patterns
            // skip the first and last to avoid generating out of range arg
            // skip denormals because there are too few bits to randomize
            pattern = lfsr64gpr (pattern, mask);
            if (index != 0 && index != count - 1)
                if (argptr16 [4] != 0)      // if exponent non-zero
                    argptr16 [0] = pattern; // replace lower 16 mantissa bits with random

            ulp = test (arg, logfile, comment);
            if (biggest < fabsl (ulp)) biggest = fabsl (ulp);
            if (!logDetail) fprintf (logfile, "%27s  %s\n", decimalLongDouble (arg), decimalLongDouble (ulp));
            if (incType == INC_LINEAR)
                mpfr_add (mpfr_arg, mpfr_arg, mpfr_inc, MPFR_RNDN);
            else if (incType == INC_LOG)
                {
                mpfr_add (mpfr_explow, mpfr_explow, mpfr_expinc, MPFR_RNDN);
                mpfr_ui_pow (mpfr_arg, 2, mpfr_explow, MPFR_RNDN);
                }
            }

    if (incType == INC_ULP)
        {
        if (end > start) ulpInc = 1; else ulpInc = -1;
        arg = start;
        for (index = 0; index < count; index++)
            {
            ulp = test (arg, logfile, comment);
            if (biggest < fabsl (ulp)) biggest = fabsl (ulp);
            if (!logDetail) fprintf (logfile, "%40s  %s\n", decimalLongDouble (arg), decimalLongDouble (ulp));
            argptr64 [0] += ulpInc;
            if (arg >= end) break;
            }
        }

    fprintf (logfile, "# largest error: %s ulp\n", decimalLongDouble (biggest));
    mpfr_clear (mpfr_arg);
    mpfr_clear (mpfr_range);
    mpfr_clear (mpfr_explow);
    mpfr_clear (mpfr_expinc);
    mpfr_clear (mpfr_start);
    mpfr_clear (mpfr_end);
    mpfr_clear (mpfr_inc);
    mpfr_clear (mpfr_temp);
    }

// command line help goes here
//
char *helpScreen (void)
   {
   printf("\nfpuaccuracy 1.0, copyright 2013 Scott Duplichan\n");
   printf("use fpuaccuracy [options]\n\n");
   printf ("options:\n");
   printf ("   ins=       x87 instruction to test (fsin,fcos,fptan,fpatan,f2xm1,fyl2x,fyl2xp1)\n");
   printf ("   start=     starting argument value\n");
   printf ("   end=       ending argument value\n");
   printf ("   count=     number of arguments to test)\n");
   printf ("   inc=       argument incrment method: linear, log, or ulp\n");
   printf ("   logfile=   log results to this file (default is stdout)\n");
   printf ("   examples   run test cases that often fail on x86 FPU\n");
   printf ("   logdetail  log arg, expected, ans actual in both hex and decimal\n");
   return NULL;
   }

//----------------------------------------------------------------------------
// main entry point for fpuaccuracy test

char *runMain (int argc, char* argv [])
    {
    int argCount;

    int logDetail = 0;
    FILE *logfile = stdout;
    INC_TYPE incType = INC_LOG;
    long double argStart = 0;
    long double argEnd = 0;
    long count = 0;

    long double (*test) () = NULL;
    double start, elapsed;

    if (argc == 1) return helpScreen ();

    argCount = argc;
    while (--argCount)
        {
        char *position = argv [argCount];

        if      (strcmp (position, "logdetail") == 0) logDetail = 1;
        else if (memcmp (position, "start=", 6) == 0) argStart = strtold (position + 6, NULL);
        else if (memcmp (position, "end=", 4) == 0) argEnd = strtold (position + 4, NULL);
        else if (memcmp (position, "count=", 6) == 0) count = strtoul (position + 6, NULL, 0);
        else if (strcmp (position, "inc=linear") == 0) incType = INC_LINEAR;
        else if (strcmp (position, "inc=log") == 0) incType = INC_LOG;
        else if (strcmp (position, "inc=ulp") == 0) incType = INC_ULP;
        else if (memcmp (position, "ins=", 4) == 0)
            {
            position += 4;
            if (strcmp (position, "fsin") == 0) test = sinTest;
            else if (strcmp (position, "fcos") == 0) test = cosTest;
            else if (strcmp (position, "fptan") == 0) test = tanTest;
            else if (strcmp (position, "fpatan") == 0) test = atanTest;
            else if (strcmp (position, "f2xm1") == 0) test = f2xm1Test;
            else if (strcmp (position, "fyl2x") == 0) test = fyl2xTest;
            else if (strcmp (position, "fyl2xp1") == 0) test = fyl2xp1Test;
            else return formatMessage ("unexpected instruction: \"%s\"\n", position);
            }

        else if (memcmp (position, "logfile=", 8) == 0)
            {
            logfile = fopen (position + 8, "w");
            if (!logfile) return formatMessage ("cannot open \"%s\" for writing", position + 8);
            }

        else if (strcmp (position, "examples") == 0)
            {
            sinTest   (3.0162653335001840718L, logfile, "sin with smallest failing argument");
            sinTest   (3.1415926535897932385L, logfile, "sin near pi");
            sinTest   (9223372035086174241.0L, logfile, "sin with large argument");
            cosTest   (1.5082562867317745453L, logfile, "cos with smallest failing argument");
            cosTest   (1.5707963267948966193L, logfile, "cos near pi/2");
            cosTest   (9223372035620657689.0L, logfile, "cos with large argument");
            tanTest   (1.4430245999997931928L, logfile, "tan with smallest failing argument");
            tanTest   (1.5707963267948966193L, logfile, "tan near pi/2");
            tanTest   (9223372036560879388.0L, logfile, "tan with large argument");
            return NULL;
            }

        else return formatMessage ("unexpected option \"%s\"", position);
        }

    start = timeit ();
    ulpList (test, argStart, argEnd, count, incType, logfile, logDetail);
    elapsed = timeit () - start;
    fprintf (logfile, "# elapsed time: %g\n", elapsed);
    if (logfile != stdout) fclose (logfile);
    return NULL;
    }

//----------------------------------------------------------------------------

int main (int argc, char *argv [])
   {
   char *error = runMain (argc, argv);
   if (error) return printf ("%s\n", error), 1;
   return 0;
   }

//----------------------------------------------------------------------------
