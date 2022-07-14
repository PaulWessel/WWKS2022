#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Plot 5 life-stages in growing volcanoes in crossection
# 		Using un-truncated Gaussian shapes with linear flux
#
# P. Wessel, April 2022
# Double-column figure in GJI so aim for W <= 17.3 cm

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
gmt begin ${dir}WWKS22_Fig_increments $1
	gmt set GMT_THEME cookbook
	gmt set FONT_ANNOT_PRIMARY 9p
	echo "100	75	50	5000	1	0" > t.txt
	gmt grdseamount -R40/160/74/76+uk -I100 -Gsmtc_%05.2f.nc t.txt -T0.8/0/0.2 -Qc/g -Dk -Cg -Mc.lis
	gmt grdseamount -R40/160/74/76+uk -I100 -Gsmti_%05.2f.nc t.txt -T0.8/0/0.2 -Qi/g -Dk -Cg -Mi.lis
	gmt subplot begin 5x2 -SCb+tc -SRl -A -R40/160/0/5.15 -Fs8c/1.3c -M8p/1p
		gmt set FONT_TAG 12p,Times-Italic,black
		gmt subplot set 0,0 -A"t = 4"
		echo "h(t)" | gmt text -F+cTR+jTR+f14p -Dj4p
		gmt grdtrack -Gsmtc_00.00.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 1,0 -A"t = 3"
		gmt grdtrack -Gsmtc_00.20.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 2,0 -A"t = 2"
		gmt grdtrack -Gsmtc_00.40.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 3,0 -A"t = 1"
		gmt grdtrack -Gsmtc_00.60.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 4,0 -A"t = 0"
		gmt grdtrack -Gsmtc_00.80.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		#
		gmt subplot set 0,1 -A"t = 4"
		echo "@~D@~h(t)" | gmt text -F+cTR+jTR+f14p -Dj4p
		gmt grdtrack -Gsmti_00.00.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 1,1 -A"t = 3"
		gmt grdtrack -Gsmti_00.20.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 2,1 -A"t = 2"
		gmt grdtrack -Gsmti_00.40.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 3,1 -A"t = 1"
		gmt grdtrack -Gsmti_00.60.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
		gmt subplot set 4,1 -A"t = 0"
		gmt grdtrack -Gsmti_00.80.nc -E40000/75000/160000/75000 -o0,2 | gmt plot -W1p -i0+s0.001,1+s0.001 -L+y0 -Gblack
	gmt subplot end
gmt end show
rm -f smt[ci]*.nc ?.lis t.txt
