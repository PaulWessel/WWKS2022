#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Plot of compilations of 1-D velocity profiles through seamounts of
# 		various sizes and from various oceans.  Left will show the velocities
# 		while the right shows predicted densities
#
# P. Wessel, April 2022

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
V2R=data/Brocher-2025-rho-v.txt
#D=/Users/pwessel/Dropbox/UH/ACTIVE/PROJECTS/OXFORD2022/For_Paul
function vztorz {	# Do the Broucher (2005) conversion
	# $1 is the data set of v,z we want to convert to r,z
	gmt sample1d ${V2R} -T$1 -o1,0 > /tmp/vr.txt
	gmt convert -A /tmp/vr.txt $1 -o0,3
}
# Grid files via Tony Watts, March 2022
#gmt grdtrack -G${D}/MGL1902_Line1_velocity.grd -E1.75/0/1.75/8 -o2,1 -s   | awk '{print $1, $2-1.5}' > data/emperor-1.txt
#gmt grdtrack -G${D}/MGL1902_Line2_velocity.grd -E142.5/0/142.5/8 -o2,1 -s | awk '{print $1, $2-1.5}' > data/emperor-2.txt

# Resample both v(z) and rho(z) finely (dz = 0.1 km)
rm -f /tmp/txt_v /tmp/txt_r
while read file; do
	vztorz data/$file | gmt sample1d -N1 -T0.05 -Fl -o1,0,0 >> /tmp/txt_r
	gmt sample1d data/$file -N1 -T0.05 -Fl -o1,0,0 >> /tmp/txt_v
done < data/files.lis
# Compute medians and MAD for 0.25 km bins
gmt blockmedian -R0/10/0/10 -I0.25/10 -r -E /tmp/txt_v -o0,2,3 > median_v.txt
gmt blockmedian -R0/10/0/10 -I0.25/10 -r -E /tmp/txt_r -o0,2,3 > median_r.txt
# Because errors are in x, build polygons with 1-s confidence bands
awk '{print $2-$3, $1}' median_v.txt > poly_v.txt
awk '{print $2+$3, $1}' median_v.txt | tail -r >> poly_v.txt
awk '{print $2-$3, $1}' median_r.txt > poly_r.txt
awk '{print $2+$3, $1}' median_r.txt | tail -r >> poly_r.txt

gmt begin ${dir}WWKS22_Fig_vp-rho-model $1
	# TL: Plot all vp(z) published curves
	gmt subplot begin 1x2 -Fs8c/5c -A+jTRL -Srl -Sct
	gmt subplot set 0
	# BL: Show the median vp(z) with 1-sigma bound
	gmt basemap -R3/7.5/0/8 -JX8c/-5c -Bxaf+l"Velocity (km/s)" -Byaf+l"Depth (km)"
	gmt plot poly_v.txt -Glightgray -l"1@~s@~ confidence"+jBL
	gmt plot median_v.txt -W2p -i1,0 -l"Median v@-p@-(z)"
	# Fit of z^p fit to median v(z) with 1/MAD as weights
	#gmt math -T0/7/0.1 T 7 DIV 0.4727 POW 4.0965 MUL 2.91 ADD = | gmt plot -W2p,red -i1,0
	printf "0 7\n8 7\n" | gmt plot -W2p,4_2:0
	gmt subplot set 1
	# BR: Show the median rho(z) with 1-sigma bound, and two models
	gmt basemap -R2.2/3.3/0/8 -JX8c/-5c -Bxaf+l"Density (kg/m@+3@+)" -Byaf+l"Depth (km)"
	gmt plot poly_r.txt -Glightgray -l"1@~s@~ confidence"+jBL
	gmt plot median_r.txt -W2p -i1,0 -l"Median @~r@~(z)"
	# Fit of z^p fit to median with 1/MAD as weights
	gmt math -T0/7/0.1 T 7 DIV 0.776 POW 0.7325 MUL 2.262 ADD = | gmt plot -W2p,red -i1,0 -l"Model A (p = 0.78)"
	# Next line shows the slight rounding reported in paper is OK
	#gmt math -T0/7/0.1 T 7 DIV 0.78 POW 0.73 MUL 2.26 ADD = | gmt plot -W0.25p -i1,0
	# Fit linear model to median with 1/MAD as weights
	gmt math -T0/7/1 T 7 DIV 0.7223 MUL 2.3327 ADD = | gmt plot -W2p,blue -i1,0 -l"Model B (linear)"
	# Next line shows the slight rounding reported in paper is OK
	#gmt math -T0/7/1 T 7 DIV 0.72 MUL 2.33 ADD = | gmt plot -Wfaint,white -i1,0
	printf "1 7\n4 7\n" | gmt plot -W2p,4_2:0
	gmt subplot end
gmt end show

rm -f median_[rv].txt poly_[rv].txt
