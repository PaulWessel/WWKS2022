#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Seamount density model available in grdseamount
#
# P. Wessel, April 2022

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
echo 0 0 50 6000 | gmt grdseamount -H6000/2500/3000+p1+d200 -Kmodel.grd -Cc -F0.2
gmt begin ${dir}WWKS22_Fig_densitymodel $1
	gmt makecpt -Cbilbao -T2500/3000 --COLOR_NAN=white
	# Plot density reference model above
	gmt grdimage model.grd -R0/1.1/0/1.1 -JX15c/5c -Bxaf+l"Normalized radial distance, @%6%r@%%" -Byafg1+l"Normalized height, @%6%h(r)@%%"
	printf "0 1\n 0.2 1\n1 0\n" | gmt plot -W0.25p
	z=0.5
	y=$(gmt math -Q 1 $z ADD 2 DIV =)
	echo 0.6 0.15 | gmt plot -Sc4p -Gwhite -W0.25p
	gmt plot -Sv12p+b+e+s -W1p -Gblack -N <<- EOF
	0.6	0.15	0.6	${z}
	0.6	1	0.6	${z}
	1.1	0	1.1	1.1
	EOF
	printf "0.6	%s\n1 %s\n" $z $z | gmt plot -W0.25p,-
	printf "0.6	%s\n0.95	%s\n" $y $y | gmt plot -W0.25p
	printf "0.6	0.3\n0.95	0.3\n" | gmt plot -W0.25p
	printf "0.6	0\n0.6	0.15\n0.95	0.15\n" | gmt plot -W0.25p
	echo 0.2 1 "@~r@~@-l@-" | gmt text -F+f10p+jTR -Dj2p -N
	echo 0 0 "@~r@~@-h@-" | gmt text -F+f10p,white+jBL -Dj2p/4p -N
	gmt text -F+f12p+jLM -Dj3p <<- EOF
	0.95	$y @[H - h(r)@[
	0.95	0.3 @[h(r) - z@[
	0.95	0.15 @[(r, z)@[
	1.05	0.55 @[H@[
	EOF
	gmt text -F+f9p+j -Dj3p <<- EOF
	0.75	$z BL Outside seamount
	0.75	$z TL Inside seamount
	EOF
	gmt colorbar -DJBC+w80%/0.25c -Bx -By+l"kg m@+-3@+"
	rm -f model.grd
gmt end show
