# fpuAccuracy
Tools to check FPU accuracy

I have ported tools from http://notabs.org/fpuaccuracy/ to Linux. 

To quote http://notabs.org/fpuaccuracy/
> Intel overstates FPU accuracy
> For nearly 20 years Intel has claimed high accuracy for the transcendental floating point instructions in its PC processor products. Intel documentation for the 1993 Pentium states: On the Pentium processor, the worst case error on functions is less than 1 ulp when rounding to the nearest-even and less than 1.5 ulps when rounding in other modes. This claim has never been true for the instructions fsin, fcos, fsincos, and fptan. The red in the plots below show ranges where the error exceeds 1.0 ulp.

## My contributions:
 - Inline GCC assembler for various x87 instructions - see [x87 documention](https://en.wikipedia.org/wiki/X86_instruction_listings#Original_8087_instructions), [details on instructions](https://www.felixcloutier.com/x86/fsin), and [GCC documentation on Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html)
 - Necessary changes to the C code
 - Makefile
 - Integration with [GNU parallel](https://www.gnu.org/software/parallel/man.html#summary_table)
 - Results on Intel Core i7-3520M CPU @ 2.90GHz 

