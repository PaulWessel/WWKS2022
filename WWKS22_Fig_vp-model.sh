#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	a) Plot of compilations of 1-D velocity profiles through seamounts of
# 		various sizes and from various oceans.
#		b) Median velocity profile and robust MAD 1-sigma confidence band
#
# P. Wessel, July 2022
# Double-column figure in GJI so aim for W <= 17.3 cm

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi

# Resample v(z) finely (dz = 0.05 km)
rm -f /tmp/txt_v
while read file; do
	gmt sample1d data/$file -N1 -T0.05 -Fl -o1,0,0 >> /tmp/txt_v
done < data/files.lis
# Compute medians and MAD for 0.25 km bins
gmt blockmedian -R0/10/0/10 -I0.25/10 -r -E /tmp/txt_v -o0,2,3 > median_v.txt
# Because errors are in x, build polygons with 1-s confidence bands
awk '{print $2-$3, $1}' median_v.txt > poly_v.txt
awk '{print $2+$3, $1}' median_v.txt | tail -r >> poly_v.txt

#---------------------------------------------------------------------
gmt begin ${dir}WWKS22_Fig_vp-model $1
	gmt subplot begin 1x2 -Fs8c/8c -A+jTR -Srl -Sct -M1p
	# a) All velocity profiles
	gmt subplot set 0
	gmt plot data/ascension-[12].txt -W1.5p,orange  -l"Ascension"+jBL -R1/8/0.125/8 -JX8c/-8c
	gmt plot data/emperor-1.txt      -W1.5p,purple  -l"Emperors"
	gmt plot data/emperor-2.txt      -W1.5p,purple
	gmt plot data/grancanary.txt     -W1.5p,yellow  -l"Gran Canaria"
	gmt plot data/greatmeteor.txt    -W1.5p,black   -l"Great Meteor"
	gmt plot data/jasper.txt         -W1.5p,blue    -l"Jasper"
	gmt plot data/josephine.txt      -W1.5p,pink    -l"Josephine"
	gmt plot data/louisville.txt     -W1.5p,red     -l"Louisville"
	gmt plot data/marquesas.txt      -W1.5p,brown   -l"Marquesas"
	gmt plot data/ninetyeast.txt     -W1.5p,magenta -l"Ninety East"
	gmt plot data/hawaii.txt         -W1.5p,green   -l"Oahu"
	gmt plot data/reunion.txt        -W1.5p,gray    -l"Réunion"
	gmt plot data/society.txt        -W1.5p,cyan    -l"Society Islands"
	gmt plot data/tenerife.txt    -W1.5p,darkgreen  -l"Tenerife"
	printf "0 7\n8 7\n" | gmt plot -W2p,4_2:0 -Bxaf+l"Velocity v@-p@- (km/s)" -Byaf+l"Depth (km)" -BWNrb
	# b) Median velocity profile and confidence band
	gmt subplot set 1
	# Show the median vp(z) with 1-sigma bound
	gmt plot  -R3/7.5/0.125/8 -JX8c/-8c poly_v.txt -Glightgray -l"1@~s@~ confidence"+jBL+o6p/1.2c
	gmt plot median_v.txt -W2p -i1,0 -l"Median v@-p@-(z)"
	printf "0 7\n8 7\n" | gmt plot -W2p,4_2:0 -BwNbr -Bxaf+l"Velocity v@-p@- (km/s)"
	gmt subplot end
gmt end show

rm -f median_v.txt poly_v.txt gmt.history
