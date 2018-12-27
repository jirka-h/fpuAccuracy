#This needed to get Process substitution https://en.wikipedia.org/wiki/Process_substitution working
SHELL=/bin/bash
JOBS=2

fpuaccuracy: fpuaccuracy.c
	gcc -O3 -Wall -Wextra -o fpuaccuracy fpuaccuracy.c -lmpfr -lm
all: fpuaccuracy commands
	parallel -j2 --joblog parallel.log --progress --verbose < commands
sin: fpuaccuracy commands
	parallel -j2 --joblog sin.log --progress --verbose < <(grep fsin commands)
cos: fpuaccuracy commands
	parallel -j2 --joblog cos.log --progress --verbose < <(grep fcos commands)
tan: fpuaccuracy commands
	parallel -j2 --joblog tan.log --progress --verbose < <(grep fptan commands)
atan: fpuaccuracy commands
	parallel -j2 --joblog atan.log --progress --verbose < <(grep fpatan commands)
#fyl2x: y * log2 x
fyl2x: fpuaccuracy commands
	parallel -j2 --joblog log2.log --progress --verbose < <(grep "fyl2x " commands)
# fyl2xp1:  y ∗ log2(x +1)
fyl2xp1: fpuaccuracy commands
	parallel -j2 --joblog log2p1.log --progress --verbose < <(grep fyl2xp1 commands)
# f2xm1: 2^(x-1)
f2xm1: fpuaccuracy commands
	parallel -j2 --joblog f2xm1.log --progress --verbose < <(grep f2xm1 commands)
plot:
	cd Results && ../plot.sh
