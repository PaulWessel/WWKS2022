#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Explain the slide parameter model
#
# P. Wessel, April 2022
# Single-column figure in GJI so aim for W = 8.4 cm

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi

gmt begin ${dir}WWKS22_Fig_slide $1
	gmt set GMT_THEME cookbook
	gmt set FONT_ANNOT_PRIMARY 9p,Times-Italic
	gmt set FONT_LABEL 12p,Times-Italic
	# Top is the model
	gmt plot -R0/2.6/0/1.2 -JX8.45c/3c -W1p -Y17c <<- EOF
	0	1
	0.2	1
	1	0
	EOF
	gmt plot -Glightgray <<-EOF
	0.36	0.2
	0.84	0.2
	0.36	0.8
	EOF
	gmt plot -Ggray <<-EOF
	0.36	0
	0.84	0
	0.84	0.2
	0.36	0.2
	EOF
	gmt plot -W0.25p,.  -Ba10f1 -Bws --MAP_FRAME_TYPE=graph <<- EOF
	> h1
	0	0.2
	0.84	0.2
	> h2
	0	0.8
	0.36	0.8
	> hc
	0	0.1
	0.92	0.1
	> rf
	0.2	0
	0.2	1
	> r2
	0.36	0
	0.36	0.8
	> r1
	0.84	0
	0.84	0.2
	> rc
	0.92	0
	0.92	0.1
	EOF
	u0=0.1
	gmt math -T0/1/0.01 ${u0} 1 ${u0} ADD T ${u0} ADD DIV 1 SUB MUL 0.8 0.2 SUB MUL 0.2 ADD -C0 0.84 0.36 SUB MUL 0.36 ADD = | gmt plot -Gpink -W1p
	gmt plot -Glightblue -W0.25p <<- EOF
	0.92	0.1
	1	0
	2.5	0
	EOF
	gmt plot -W0.25p,dashed <<- EOF
	>
	0.28	0.9
	0.75	0.9
	> 
	0.44	0.4
	1.05	0.4
	EOF
	gmt text -F+f9p,Times-Italic+j -N -Dj4p <<- EOF
	0.00	0.1	RM	h@-c@-
	0.60	1.12	CB	Cross-section parameters
	0.00	1.0	RM	h@-0@-
	0.00	0.23	RM	h@-1@-
	0.00	0.8	RM	h@-2@-
	0.00	1.1	RB	h
	0.20	0	TC	r@-f@-
	0.36	0	TC	r@-2@-
	0.83	0	TC	r@-1@-
	0.92	0	TC	r@-c@-
	1.02	0	TC	r@-0@-
	2.50	0	TC	r@-d@-
	2.75	0	TC	r
	1.02	0.4	LM	h@-s@-(r)
	0.72	0.9	LM	h(r)
	2.30	1.12	CB	Map view parameters
	1.85	0.98	LM	@~a@~@-1@-
	2.65	0.80	LM	@~a@~@-2@-
	EOF
	echo 2.3 0.6 | gmt plot -Sw1i/20/140 -Glightgray -N
	echo 2.3 0.6 0.4i 20 140 | gmt plot -Sm10p+b -W0.5p -Gblack -N
	echo 2.3 0.6 | gmt plot -Sc1i -W1p -N
	echo "a)" | gmt text -F+cTL+f16p -N -D-30p/4p
	# Next is u0
	gmt basemap -R0/1/0/1 -JX8.45c/3c -Bxaf+p"u = " -Byaf+l"q(u)" -Y-3.8c
	u0=0.002
	gmt math -T0/1/0.001 $u0 1 $u0 ADD T $u0 ADD DIV 1 SUB MUL = | gmt plot -W1p,red -l"u@-0@- = ${u0}"
	u0=0.02
	gmt math -T0/1/0.01 $u0 1 $u0 ADD T $u0 ADD DIV 1 SUB MUL = | gmt plot -W1p,black -l"u@-0@- = ${u0}"
	u0=0.1
	gmt math -T0/1/0.01 $u0 1 $u0 ADD T $u0 ADD DIV 1 SUB MUL = | gmt plot -W1p,blue -l"u@-0@- = ${u0}"
	u0=0.5
	gmt math -T0/1/0.01 $u0 1 $u0 ADD T $u0 ADD DIV 1 SUB MUL = | gmt plot -W1p,green -l"u@-0@- = ${u0}"
	printf "0 1\n1 0\n" | gmt plot -W0.25p,-
	gmt legend -DjTR+o3p -F+p1p+gwhite
	echo "b)" | gmt text -F+cTL+f16p -N -D-30p/4p
	echo "Radial slide shape parameter" | gmt text -F+cTC+f9p -N -D-12p/-4p
	# Last is azimuthal
	gmt basemap -R-1/1/0/1 -JX8.45c/3c -Bxaf+p"@~g@~ = " -Byaf+l"s(@~g@~)" -Y-3.9c
	v=2;	s_bar=$(gmt math -Q 1 1 $v 1 ADD DIV SUB =)
	gmt math -T-1/1/0.001 1 T ABS $v POW SUB = | gmt plot -W1p,red -l"@%6%p = 2@%%"+jBC
	gmt math -T-1/1/2 $s_bar = | gmt plot -W0.5p,red,-
	v=6;	s_bar=$(gmt math -Q 1 1 $v 1 ADD DIV SUB =)
	gmt math -T-1/1/0.001 1 T ABS $v POW SUB = | gmt plot -W1p,green -l"@%6%p = 8@%%"
	gmt math -T-1/1/2 $s_bar = | gmt plot -W0.5p,green,-
	v=25;	s_bar=$(gmt math -Q 1 1 $v 1 ADD DIV SUB =)
	gmt math -T-1/1/0.001 1 T ABS $v POW SUB = | gmt plot -W1p,blue -l"@%6%p = 25@%%"
	gmt math -T-1/1/2 $s_bar = | gmt plot -W0.5p,blue,-
	v=10000;	s_bar=$(gmt math -Q 1 1 $v 1 ADD DIV SUB =)
	gmt math -T-1/1/0.001 1 T ABS $v POW SUB = | gmt plot -W1p,black -l"@%6%p = @~\245@~@%%"
	gmt math -T-1/1/2 $s_bar = | gmt plot -W0.5p,black,-
	gmt legend -DjCB+o24p/3p -F+p1p+gwhite
	echo "c)" | gmt text -F+cTL+f16p -N -D-30p/4p
	echo "Slide azimuthal parameter" | gmt text -F+cBL+f9p -N -Dj10p/4p
	# Next is psi
	gmt basemap -R0/1/0/1 -JX8.45c/3c -Bxafg0.5+p"@~t@~ = " -Byafg0.5+l"@~y(t)@~" -Y-3.9c
	beta=1;
	gmt math -T0/1/0.001 T ABS $beta POW = | gmt plot -W1p,black -l"@~b@~ = ${beta}"+jBR
	beta=2
	gmt math -T0/1/0.001 T ABS $beta POW = | gmt plot -W1p,blue -l"@~b@~ = ${beta}"
	beta=4
	gmt math -T0/1/0.001 T ABS $beta POW = | gmt plot -W1p,green -l"@~b@~ = ${beta}"
	beta=0.3
	gmt math -T0/1/0.001 T ABS $beta POW = | gmt plot -W1p,red -l"@~b@~ = 1/3"
	gmt legend -DjBR+o3p -F+p1p+gwhite
	echo "d)" | gmt text -F+cTL+f16p -N -D-30p/4p
	echo "Slide time-evolution parameter" | gmt text -F+cTL+f9p -N -Dj4p
gmt end show
