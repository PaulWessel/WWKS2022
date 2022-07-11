#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Parabolic seamount model
# 		P. Wessel, April 2022
# Single-column figure in GJI so aim for W = 8.4 cm

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
gmt begin ${dir}WWKS22_Fig_parabola $1
	gmt set MAP_VECTOR_SHAPE 0.5
	echo "0	1" > /tmp/tmp
	echo "1	1" >> /tmp/tmp
	gmt math -T1/4.1/0.1 T 4 DIV 2 POW NEG 1 ADD 1 0.25 2 POW SUB DIV = >> /tmp/tmp
	gmt math -T-4/-1/0.1 T 4 DIV 2 POW NEG 1 ADD 1 0.25 2 POW SUB DIV = /tmp/body
	gmt math -T1/4/0.1 T 4 DIV 2 POW NEG 1 ADD 1 0.25 2 POW SUB DIV = >> /tmp/body
	gmt math -T-4/4/0.1 T 4 DIV 2 POW NEG 1 ADD 1 0.25 2 POW SUB DIV = /tmp/line
	gmt plot -R-5/5/0/1.5 -JX8.4c/1.6c -Glightgray /tmp/body
	gmt plot -W2p /tmp/tmp
	gmt plot -W0.5p,- /tmp/line
	gmt plot -Sv0.1i+e+s -Gblack -W0.5p -N <<- EOF
	-5	0	5	0
	0	0	0	1.5
	EOF
	gmt plot -W0.25p,- <<- EOF
	>
	-0.5	0.2
	4.3	0.2
	>
	1	0
	1	1
	>
	3.60555	0
	3.60555	0.3
	EOF
	gmt text -F+f9p,Times-Italic+j -N <<- EOF
	1	-0.05	TC	r@-f@- = fr@-0@-
	4	-0.05	TC	r@-0@-
	3.60555	-0.05	TC	r@-n@-
	4.3	0.2	LM	h@-n@-
	-0.2	1	RM	h@-0@-
	EOF
gmt end show
