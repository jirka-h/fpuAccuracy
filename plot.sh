#!/bin/bash
TITLE_PREFIX=$(lscpu | grep "Model name:" | awk -F':[[:blank:]]*' '{print $2}')
COMMAND_FILE=plotcmds.txt

[ -f fyl2x-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FYL2X (1.0-2.0)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics 1.0,1.5,2.0 format "%.3f
set output "fyl2x-r1.png"
set logscale x
plot "< xzcat fyl2x-r1.txt.xz" notitle with dots
EOF

[ -f fyl2x-r2.txt.xz ] && gnuplot <<EOF
set xtics 0.6,1.1,1.7 format "%.3f"
set title "$TITLE_PREFIX FYL2X (0.6 to 1.7)"
set xlabel "Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set output "fyl2x-r2.png"
set logscale x
plot "< xzcat fyl2x-r2.txt.xz" notitle with dots
EOF

[ -f fyl2x-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FYL2X (0001-7FFD)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("0001" 0, "1000" 131048, "2000" 262128, "3000" 393208, "4000" 524288, "5000" 655368, "6000" 786448, "7000" 917528, "7FFD" 1048511)
set output "fyl2x-r3.png"
plot "< xzcat fyl2x-r3.txt.xz" using :2 notitle with dots
EOF

[ -f fyl2xp1-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FYL2XP1 (0001-3FFE)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("0001" 0, "1000" 262096, "2000" 524256, "3000" 786416, "3FFE" 1048448)
set output "fyl2xp1-r1.png"
plot "< xzcat fyl2xp1-r1.txt.xz" using :2 notitle with dots
EOF

[ -f fyl2xp1-r2.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FYL2XP1 (3FBE-3FC5)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("3FBE" 0, "3FBF" 0x20000, "3FC0" 0x40000, "3FC1" 0x60000, "3FC2" 0x80000, "3FC3" 0xA0000, "3FC4" 0xC0000, "3FC5" 0xE0000)
set output "fyl2xp1-r2.png"
plot "< xzcat fyl2xp1-r2.txt.xz" using :2 notitle with dots
EOF

[ -f fyl2xp1-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FYL2XP1 (3FEB-3FFE)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("3FEB" 0, "3FED" 0x19999, "3FEF" 0x33333, "3FF1" 0x4CCCC, "3FF3" 0x66666, "3FF5" 0x80000, "3FF7" 0x99999, "3FF9" 0xB3333, "3FFB" 0xCCCCC, "3FFD" 0xE6666)
set output "fyl2xp1-r3.png"
plot "< xzcat fyl2xp1-r3.txt.xz" using :2 notitle with dots
EOF

[ -f f2xm1-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX F2XM1 (0001-3FFE)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("0001" 0, "1000" 262096, "2000" 524256, "3000" 786416, "3FFE" 1048448)
set output "f2xm1-r1.png"
plot "< xzcat f2xm1-r1.txt.xz" using :2 notitle with dots
EOF

[ -f f2xm1-r2.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX F2XM1 (3FBA-3FFE)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("3FBA" 0, "3FC3" 0x21642, "3FCC" 0x42C85, "3FD5" 0x642C8, "3FDE" 0x8590B, "3FE7" 0xA6F4D, "3FF0" 0xC8590, "3FF9" 0xE9BD3)
set output "f2xm1-r2.png"
plot "< xzcat f2xm1-r2.txt.xz" using :2 notitle with dots
EOF

[ -f f2xm1-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX F2XM1 (3FFD-3FFE)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("3FFD" 0, "3FFE" 0x80000)
set output "f2xm1-r3.png"
plot "< xzcat f2xm1-r3.txt.xz" using :2 notitle with dots
EOF

[ -f f2xm1-r4.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX F2XM1 (-0.01 to +0.01)"
set xlabel "Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set output "f2xm1-r4.png"
plot "< xzcat f2xm1-r4.txt.xz" notitle with dots
EOF

[ -f f2xm1-r5.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX F2XM1 (-1.0 to +1.0)"
set xlabel "Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set output "f2xm1-r5.png"
plot "< xzcat f2xm1-r5.txt.xz" notitle with dots
EOF

[ -f fpatan-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPATAN (0001-7FFD)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("0001" 0, "1000" 131048, "2000" 262128, "3000" 393208, "4000" 524288, "5000" 655368, "6000" 786448, "7000" 917528, "7FFD" 1048511)
set output "fpatan-r1.png"
plot "< xzcat fpatan-r1.txt.xz" using :2 notitle with dots
EOF

[ -f fpatan-r2.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPATAN (3FCA-4055)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("3FCA" 0, "3FDA" 0x1D41D, "3FEA" 0x3A83A, "3FFA" 0x57C57, "400A" 0x75075, "401A" 0x92492, "402A" 0xAF8AF, "403A" 0xCCCCC, "404A" 0xEA0EA)
set output "fpatan-r2.png"
plot "< xzcat fpatan-r2.txt.xz" using :2 notitle with dots
EOF

[ -f fpatan-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPATAN (3FFA-4000)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "Error in ULPs"
set grid
set term png size 1280,800
set xtics ("3FFA" 0, "3FFB" 0x20000, "3FFC" 0x40000, "3FFD" 0x60000, "3FFE" 0x80000, "3FFF" 0xA0000, "4000" 0xC0000, "4001" 0xE0000)
set output "fpatan-r3.png"
plot "< xzcat fpatan-r3.txt.xz" using :2 notitle with dots
EOF

[ -f fcos-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FCOS near pi/2"
set xlabel "Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set xtics ("1.47" 0, "1.508" 180038, "pi/2" 524289, "1.67" 1048578)
set ytics scale 1,0 0.001,10,100000 format "%.11G"
set logscale y
set grid
set term png size 1280,800
set output "fcos-r1.png"
plot "< xzcat fcos-r1.txt.xz" using :(abs (\$2)) notitle with dots
set term png size 640,400
set output "fcos-r1-small.png"
plot "< xzcat fcos-r1.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fcos-r2.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FCOS (3FD0-403E)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set logscale y
set xtics ("pi/2" 1816954, "3FD0" 0, "3FD8" 0x4B27E, "3FE0" 0x964FD, "3FE8" 0xE177C, "3FF0" 0x12C9FB, "3FF8" 0x177C7A, "4008" 0x20E177, "4010" 0x2593F6, "4018" 0x2A4675, "4020" 0x2EF8F4, "4028" 0x33AB73, "4030" 0x385DF1, "4038" 0x3D1070)
set ytics scale 1,0 1E-10,10,1E+25 format "%.6G"
set grid
set term png size 1280,800
set output "fcos-r2.png"
plot "< xzcat fcos-r2.txt.xz" using :(abs (\$2)) notitle with dots
set term png size 640,400
set output "fcos-r2-small.png"
set ytics scale 1,0 1E-10,100,1E+25 format "%.6G"
plot "< xzcat fcos-r2.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fcos-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FCOS, area surrounding maximum error"
set xlabel "Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set logscale y
set xtics ("9223372035619609113" 0, "maximum error arg (9223372035620657689)" 2097153)
set grid
set term png size 1280,800
set output "fcos-r3.png"
plot "< xzcat fcos-r3.txt.xz" using :(abs (\$2)) notitle with dots
set term png size 640,400
set output "fcos-r3-small.png"
plot "< xzcat fcos-r3.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fsin-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FSIN near pi"
set xlabel "Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set xtics ("2.95" 0, "3.016" 179358, "pi" 524289, "3.34" 1048578)
set ytics scale 1,0 0.001,10,100000 format "%.11G"
set grid
set term png size 1280,800
set output "fsin-r1.png"
set logscale y
plot "< xzcat fsin-r1.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fsin-r2.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FSIN (3FD0-403E)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set grid
set term png size 1280,800
set output "fsin-r2.png"
set logscale y
set xtics ("pi" 1855084, "3FD0" 0, "3FD8" 0x4B27E, "3FE0" 0x964FD, "3FE8" 0xE177C, "3FF0" 0x12C9FB, "3FF8" 0x177C7A, "4008" 0x20E177, "4010" 0x2593F6, "4018" 0x2A4675, "4020" 0x2EF8F4, "4028" 0x33AB73, "4030" 0x385DF1, "4038" 0x3D1070)
set ytics scale 1,0 1E-10,10,1E+25 format "%.6G"
plot "< xzcat fsin-r2.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fsin-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FSIN, area surrounding maximum error"
set xlabel "Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set logscale y
set xtics ("9223372035085125665" 0, "maximum error arg (9223372035086174241)" 2097153)
set grid
set term png size 1280,800
set output "fsin-r3.png"
plot "< xzcat fsin-r3.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fptan-r1.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPTAN near pi/2"
set xlabel "Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set xtics ("1.47" 0, "1.508" 180038, "pi/2" 524289, "1.67" 1048578)
set ytics scale 1,0 0.001,10,100000 format "%.11G"
set grid
set term png size 1280,800
set output "fptan-r1.png"
set logscale y
plot "< xzcat fptan-r1.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fptan-r2.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPTAN (3FD0-403E)"
set xlabel "Biased Exponent of Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set grid
set term png size 1280,800
set output "fptan-r2.png"
set logscale y
set xtics ("pi/2" 1816954, "3FD0" 0, "3FD8" 0x4B27E, "3FE0" 0x964FD, "3FE8" 0xE177C, "3FF0" 0x12C9FB, "3FF8" 0x177C7A, "4008" 0x20E177, "4010" 0x2593F6, "4018" 0x2A4675, "4020" 0x2EF8F4, "4028" 0x33AB73, "4030" 0x385DF1, "4038" 0x3D1070)
set ytics scale 1,0 1E-10,10,1E+25 format "%.6G"
plot "< xzcat fptan-r2.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fptan-r3.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPTAN, area surrounding maximum error"
set xlabel "Extended Precision input Argument"
set ylabel "abs (error in ULPs)"
set logscale y
set xtics ("9223372036559830812" 0, "maximum error arg (9223372036560879388)" 2097153)
set grid
set term png size 1280,800
set output "fptan-r3.png"
plot "< xzcat fptan-r3.txt.xz" using :(abs (\$2)) notitle with dots
set term png size 640,400
set output "fptan-r3-small.png"
plot "< xzcat fptan-r3.txt.xz" using :(abs (\$2)) notitle with dots
EOF

[ -f fcos-r4.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FCOS ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "cos (x)"
set ytics -1,0.2,1
set xtics ("0" 0, "0.5 pi" pi*0.5, "pi" pi, "1.5pi" pi*1.5, "2.0 pi" pi*2.0)
set grid
set term png size 1280,800
set output "fcos-r4.png"
plot "< xzcat fcos-r4.txt.xz" using (\$1):(cos (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? cos (\$1):NaN) notitle with boxes lc 1
set term png size 640,400
set output "fcos-r4-small.png"
plot "< xzcat fcos-r4.txt.xz" using (\$1):(cos (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? cos (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fcos-r5.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FCOS ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "cos (x)"
set ytics -1,0.2,1
set xtics ("0" 0, "0.5 pi" pi*0.5, "pi" pi, "1.5pi" pi*1.5, "2.0 pi" pi*2.0)
set grid
set term png size 1280,600
set output "fcos-r5.png"
plot "< xzcat fcos-r5.txt.xz" using (\$1):(cos (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? cos (\$1):NaN) notitle with boxes lc 1
set term png size 640,300
set output "fcos-r5-small.png"
plot "< xzcat fcos-r5.txt.xz" using (\$1):(cos (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? cos (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fcos-r6.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FCOS ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "cos (x)"
set ytics -1,0.2,1
set xtics ("0" 0, "8 pi" pi*8.0, "16 pi" pi*16.0, "24 pi" pi*24.0, "32 pi" pi*32.0)
set grid
set term png size 1280,400
set output "fcos-r6.png"
plot "< xzcat fcos-r6.txt.xz" using (\$1):(cos (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? cos (\$1):NaN) notitle with boxes lc 1
set term png size 640,200
set ytics -1,0.5,1
set output "fcos-r6-small.png"
plot "< xzcat fcos-r6.txt.xz" using (\$1):(cos (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? cos (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fsin-r4.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FSIN ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "sin (x)"
set ytics -1,0.2,1
set xtics ("0" 0, "0.5 pi" pi*0.5, "pi" pi, "1.5pi" pi*1.5, "2.0 pi" pi*2.0)
set grid
set term png size 1280,800
set output "fsin-r4.png"
plot "< xzcat fsin-r4.txt.xz" using (\$1):(sin (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? sin (\$1):NaN) notitle with boxes lc 1
set term png size 640,400
set output "fsin-r4-small.png"
plot "< xzcat fsin-r4.txt.xz" using (\$1):(sin (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? sin (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fsin-r5.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FSIN ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "sin (x)"
set ytics -1,0.2,1
set xtics ("0" 0, "0.5 pi" pi*0.5, "pi" pi, "1.5pi" pi*1.5, "2.0 pi" pi*2.0)
set grid
set term png size 1280,600
set output "fsin-r5.png"
plot "< xzcat fsin-r5.txt.xz" using (\$1):(sin (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? sin (\$1):NaN) notitle with boxes lc 1
set term png size 640,300
set output "fsin-r5-small.png"
plot "< xzcat fsin-r5.txt.xz" using (\$1):(sin (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? sin (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fsin-r6.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FSIN ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "sin (x)"
set ytics -1,0.2,1
set xtics ("0" 0, "8 pi" pi*8.0, "16 pi" pi*16.0, "24 pi" pi*24.0, "32 pi" pi*32.0)
set grid
set term png size 1280,400
set output "fsin-r6.png"
plot "< xzcat fsin-r6.txt.xz" using (\$1):(sin (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? sin (\$1):NaN) notitle with boxes lc 1
set term png size 640,200
set output "fsin-r6-small.png"
set ytics -1,0.5,1
plot "< xzcat fsin-r6.txt.xz" using (\$1):(sin (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? sin (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fptan-r4.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPTAN ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "tan (x)"
set yrange [-10:10]
set ytics -10,1,10
set xtics ("0" 0, "0.5 pi" pi*0.5, "pi" pi, "1.5pi" pi*1.5, "2.0 pi" pi*2.0)
set grid
set term png size 1280,800
set output "fptan-r4.png"
plot "< xzcat fptan-r4.txt.xz" using (\$1):(tan (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? tan (\$1):NaN) notitle with boxes lc 1
set term png size 640,400
set output "fptan-r4-small.png"
plot "< xzcat fptan-r4.txt.xz" using (\$1):(tan (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? tan (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fptan-r5.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPTAN ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "tan (x)"
set yrange [-10:10]
set ytics -10,1,10
set xtics ("0" 0, "0.5 pi" pi*0.5, "pi" pi, "1.5pi" pi*1.5, "2.0 pi" pi*2.0)
set grid
set term png size 1280,600
set output "fptan-r5.png"
plot "< xzcat fptan-r5.txt.xz" using (\$1):(tan (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? tan (\$1):NaN) notitle with boxes lc 1
set term png size 640,300
set output "fptan-r5-small.png"
set ytics -10,2,10
plot "< xzcat fptan-r5.txt.xz" using (\$1):(tan (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? tan (\$1):NaN) notitle with boxes lc 1
EOF

[ -f fptan-r6.txt.xz ] && gnuplot <<EOF
set title "$TITLE_PREFIX FPTAN ranges where error >= 1.0 ulp"
set xlabel "Extended Precision input Argument"
set ylabel "tan (x)"
set yrange [-10:10]
set ytics -10,1,10
set xtics ("0" 0, "8 pi" pi*8.0, "16 pi" pi*16.0, "24 pi" pi*24.0, "32 pi" pi*32.0)
set grid
set term png size 1280,400
set output "fptan-r6.png"
plot "< xzcat fptan-r6.txt.xz" using (\$1):(tan (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? tan (\$1):NaN) notitle with boxes lc 1
set term png size 640,200
set ytics -10,5,10
set output "fptan-r6-small.png"
plot "< xzcat fptan-r6.txt.xz" using (\$1):(tan (\$1)) notitle with boxes lc 2, "" using (\$1):((abs (\$2) >= 1.0)? tan (\$1):NaN) notitle with boxes lc 1
EOF

