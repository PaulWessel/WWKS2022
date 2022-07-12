#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Conical seamount model
#
# P. Wessel, April 2022
# Single-column figure in GJI so aim for W = 8.4 cm

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
gmt begin ${dir}WWKS22_Fig_cone $1
	gmt set MAP_VECTOR_SHAPE 0.5
	cat <<- EOF > /tmp/tmp
	0	1
	1	1
	5	-0.33333
	EOF
	cat <<- EOF > /tmp/body
	-4	0
	-1	1
	0	1
	1	1
	4	0
	EOF
	gmt plot -R-5/5/0/1.5 -JX8.4c/1.6c  -Glightgray /tmp/body
	gmt plot -W2p /tmp/tmp
	gmt plot -W0.5p,- <<- EOF
	-4	0
	0	1.33333
	4	0
	EOF
	gmt plot -Sv0.1i+e+s -Gblack -W0.5p -N <<- EOF
	-5	0	5	0
	0	0	0	1.7
	EOF
	gmt plot -W0.25p,- <<- EOF
	>
	-0.5	0.2
	4.3	0.2
	>
	1	0
	1	1
	>
	3.4	0
	3.4	0.3
	EOF
	gmt text -F+f9p,Times-Italic+j -N <<- EOF
	1	-0.05	TC	r@-f@- = fr@-0@-
	4	-0.05	TC	r@-0@-
	3.4	-0.05	TC	r@-n@-
	4.3	0.22	LM	h@-n@-
	-0.2	1	RM	h@-0@-
	EOF
gmt end show
