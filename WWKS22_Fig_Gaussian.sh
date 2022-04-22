#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Gaussian seamount model
#
# P. Wessel, April 2022

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
gmt begin ${dir}WWKS22_Fig_Gaussian $1
	gmt set MAP_VECTOR_SHAPE 0.5
	echo "0	1" > /tmp/tmp
	echo "1	1" >> /tmp/tmp
	gmt math -T1/4/0.1 T 4 DIV 2 POW 4.5 MUL NEG EXP 0.25 2 POW 4.5 MUL EXP MUL = >> /tmp/tmp
	gmt math -T-4/-1/0.1 T 4 DIV 2 POW 4.5 MUL NEG EXP 0.25 2 POW 4.5 MUL EXP MUL = /tmp/body
	gmt math -T1/4/0.1 T 4 DIV 2 POW 4.5 MUL NEG EXP 0.25 2 POW 4.5 MUL EXP MUL = >> /tmp/body
	gmt math -T-4/4/0.1 T 4 DIV 2 POW 4.5 MUL NEG EXP 0.25 2 POW 4.5 MUL EXP MUL = /tmp/line
	gmt plot -R-5/5/-0.05/1.35 -JX6.5i/1.25i -Glightgray /tmp/body
	gmt plot -W2p /tmp/tmp
	gmt plot -W0.5p,- /tmp/line
	gmt plot -Sv0.1i+e+s -Gblack -W0.5p -N <<- EOF
	-5	0	5	0
	0	0	0	1.6
	EOF
	gmt plot -W0.25p,- <<- EOF
	>
	-0.5	0.2
	4.3	0.2
	>
	1	0
	1	1
	>
	2.59	0
	2.59	0.3
	EOF
	gmt text -F+f16p,Times-Italic+j -N <<- EOF
	1	-0.05	TC	r@-f@- = fr@-0@-
	4	-0.05	TC	r@-0@-
	4.3	0.2	LM	h@-n@-
	2.59	-0.05	TC	r@-n@-
	-0.2	1	RM	h@-0@-
	EOF
gmt end show
