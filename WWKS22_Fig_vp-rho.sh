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
# Moore, 2001 mean density ranges
cat << EOF > moore.txt
2.550	0.950	0.240	0.050
3.010	2.050	0.100	0.050
2.670	2.333	0.130	0.125
2.890	2.705	0.170	0.050
2.970	3.000	0.080	0.090
EOF
# Hyndman et al, 1979 Azores mean density ranges
cat << EOF > hyndman.txt
2.60	0.400	0.200	0.400
2.71	0.800	0.100	0.050
2.79	0.925	0.100	0.075
EOF
gmt begin ${dir}WWKS22_Fig_vp-rho $1
	# TL: Plot all vp(z) published curves
	gmt subplot begin 1x2 -Fs8c/9c -A+jTR -Srl -Sct
	gmt subplot set 0
	gmt basemap -R1/8/0/8 -JX8c/-9c -Bxaf+l"Velocity (km/s)" -Byaf+l"Depth (km)"
	gmt plot poly_v.txt -Glightgray
	gmt plot median_v.txt -W2p -i1,0
	gmt plot data/ascension-[12].txt -W1.5p,orange  -l"Ascension"+jBL
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
	printf "0 7\n8 7\n" | gmt plot -W2p,4_2:0
	# TR: Plot the straight conversion of vp(z) to rho(z)
	gmt subplot set 1
	gmt basemap -R1.5/3.5/0/8 -JX8c/-9c -Bxaf+l"Density (kg/m@+3@+)" -Byaf+l"Depth (km)"
	gmt plot poly_r.txt -Glightgray
	gmt plot median_r.txt -W2p -i1,0
	vztorz data/ascension-1.txt | gmt plot -W1.5p,orange
	vztorz data/ascension-2.txt | gmt plot -W1.5p,orange
	vztorz data/emperor-1.txt   | gmt plot -W1.5p,purple
	vztorz data/emperor-2.txt   | gmt plot -W1.5p,purple
	vztorz data/grancanary.txt  | gmt plot -W1.5p,yellow
	vztorz data/greatmeteor.txt | gmt plot -W1.5p,black
	vztorz data/jasper.txt      | gmt plot -W1.5p,blue
	vztorz data/josephine.txt   | gmt plot -W1.5p,pink
	vztorz data/louisville.txt  | gmt plot -W1.5p,red
	vztorz data/marquesas.txt   | gmt plot -W1.5p,brown
	vztorz data/ninetyeast.txt  | gmt plot -W1.5p,magenta
	vztorz data/hawaii.txt      | gmt plot -W1.5p,green
	vztorz data/reunion.txt     | gmt plot -W1.5p,gray
	vztorz data/society.txt     | gmt plot -W1.5p,cyan
	vztorz data/tenerife.txt    | gmt plot -W1.5p,darkgreen
	printf "1 7\n4 7\n"    | gmt plot -W2p,4_2:0
	gmt plot moore.txt -Sc5p -Gred -E+p1p -l"Moore (2001)"+jBL
	gmt plot hyndman.txt -Sc5p -Gblue -E+p1p -l"Hyndman et al (1979)"
	gmt subplot end
gmt end show

rm -f median_[rv].txt poly_[rv].txt moore.txt hyndman.txt gmt.history
