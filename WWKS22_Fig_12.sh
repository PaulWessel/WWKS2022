#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Plot of compilations of 1-D velocity profiles through seamounts of
# 		various sizes and from various oceans.  Left will show the velocities
# 		while the right shows predicted densities
#
# P. Wessel, July 2022
# Single-column figure in GJI so aim for W <= 8.4 cm

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
# Crate density vs depth models
bash make_cr_model.sh

gmt begin ${dir}WWKS22_Fig_12 $1
	# BR: Show the median rho(z) with 1-sigma bound, and two models
	gmt set PS_LINE_CAP round 
	gmt plot -R2.0/3.13/0.125/8 -JX8c/-8c B2005_conf.txt -i1,0 -Glightblue@50
	gmt plot B2005_model.txt -W2p,blue -i1,0 -l"Broucher (2005)"+jBL
	#gmt plot ND1970_conf.txt -i1,0 -Glightblue@50
	#gmt plot ND1970_model.txt -W2p,blue -i1,0 -l"Nafe & Drake (1970)"
	gmt plot CR1984_conf.txt -i1,0 -Glightpink@50
	gmt plot CR1984_model.txt -i1,0 -W2p,red -l"Carlson & Raskin (1984)"
	gmt plot B2005_model.txt -W2p,green -i1,0
	#gmt plot ND1970_model.txt -W2p,blue -i1,0
	#gmt plot B2005_conf.txt ND1970_conf.txt CR1984_conf.txt -i1,0 -Wfaint 
	#gmt plot B2005_conf.txt CR1984_conf.txt -i1,0 -Wfaint 
	# Fit of z^p fit to median with 1/MAD as weights
	gmt math -T0/7/0.1 T 7 DIV 0.776 POW 0.7325 MUL 2.262 ADD = | gmt plot -W1.5p -i1,0 -l"Model A (p = 0.78)"
	# Next line shows the slight rounding reported in paper is OK
	#gmt math -T0/7/0.1 T 7 DIV 0.78 POW 0.73 MUL 2.26 ADD = | gmt plot -W0.25p -i1,0
	# Fit linear model to median with 1/MAD as weights
	gmt math -T0/7/1 T 7 DIV 0.7223 MUL 2.3327 ADD = | gmt plot -W1.5p,black,5_3,1 -i1,0 -l"Model B (linear)"
	# Next line shows the slight rounding reported in paper is OK
	#gmt math -T0/7/1 T 7 DIV 0.72 MUL 2.33 ADD = | gmt plot -Wfaint,white -i1,0
	printf "1 7\n4 7\n" | gmt plot -W2p,4_2:0 -Bxaf+l"Density (kg/m@+3@+)" -Byaf+l"Depth (km)" -BWbNr
	#gmt set PS_LINE_CAP round 
	#gmt math -T0/7/0.1 T 7 DIV 0.28 POW 0.83 MUL 2.15 ADD = | gmt plot -W1.5p,black,2_3:0 -i1,0 -l"Model C (p = 0.28)"
	gmt math -T0/7/0.1 T 7 DIV 0.19 POW 1.0733 MUL 1.8952 ADD = | gmt plot -W1.5p,black,0_3:4 -i1,0 -l"Model C (p = 0.19)"
	#gmt set PS_LINE_CAP round 
	#gmt plot CR1984_conf.txt -i1,0 -Glightpink@50
	#gmt plot CR1984_model.txt -i1,0 -W3p,black,0_5:0 -l"Carlson & Raskin (1984)"
	#gmt plot cr_mod.txt -W3p,black,0_5:0 -l"C & R (1984)"
	gmt plot data/moore.txt -Sc4p -Gred -E+p0.5p -l"Moore (2001)"
	gmt plot data/hyndman.txt -Sc4p -Gblue -E+p0.5p -l"Hyndman et al (1979)"
	#grep -v '^#' /Users/pwessel/Dropbox/UH/ACTIVE/PROJECTS/OXFORD2022/EMPERORS/Site_*_properties.txt | awk '{print $6, 0.001*$3}' | gmt plot -Sc2p -Gorange -l"197 & 330"
gmt end show

# Clean up and remove temp files
rm -f median_v.txt poly_v.txt
rm -f CR1984_model.txt B2005_model.txt ND1970_model.txt CR1984_zrw.txt
rm -f CR1984_conf.txt B2005_conf.txt ND1970_conf.txt
