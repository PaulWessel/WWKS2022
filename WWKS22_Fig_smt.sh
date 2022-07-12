#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Bathymetry maps of large and small seamounts
#
# P. Wessel, April 2022

# Need grids: osm18bathy.grd smt_bathy.grd
# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
gmt begin ${dir}WWKS22_Fig_smt $1
	gmt set GMT_THEME cookbook
	
	# one of the Magellan seamounts 
	gmt makecpt -Cturbo -T-5000/-1000 --COLOR_NAN=white
	gmt grdimage -R152.3/152.924761672/19.0059625964/19.4350703422 data/osm18bathy.grd -I+d -JM6c+dh --COLOR_NAN=white -B
	gmt colorbar -DJBC -Bxaf -By+lm
	gmt inset begin -DjTL+w2.2c+o0.2c/0.2c -F+gwhite+p1p+c0.1c
		gmt coast -Rg -JG152/19N/? -Da -Gbisque -A5000 -Bg -Wfaint -Slightblue
		echo "152 19" | gmt plot -St0.3c -Gred -Wfaint
	gmt inset end
	echo "a)" | gmt text -F+jTR+f24p+cTL -N -Dj0.8c/0
	# small seamounts near Clarion-Clipperton FZ
	gmt makecpt -Cturbo -T-6000/-4000 --COLOR_NAN=white
	gmt grdimage -Rdata/smt_bathy.grd data/smt_bathy.grd -I+d -JM6c+dh -B -X10.5c
	gmt colorbar -DJBC -B -Bxaf -By+lm
	gmt inset begin -DjTL+w2.2c+o0.2c/0.2c -F+gwhite+p1p+c0.1c
		gmt coast -Rg -JG-149:50/16S/? -Da -Gbisque -A5000 -Bg -Wfaint -Slightblue
		echo "-149:50 -16" | gmt plot -St0.3c -Gred -Wfaint
	gmt inset end
	echo "b)" | gmt text -F+jTR+f24p+cTL -N -Dj0.8c/0

gmt end show
