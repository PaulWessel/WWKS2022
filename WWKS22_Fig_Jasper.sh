#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Jasper seamount 3-D view density structure and gravity anomaly
# Fig:	Jasper seamount profile and anomaly
#
# P. Wessel, April 2022

if [ -d calc ]; then	# Nothing to do
	echo "WWKS22_Fig_Jasper: Directory calc exist so we will reuse those results."
	echo "WWKS22_Fig_Jasper: Delete the calc directory if you want to start fresh."
else	# First compute grids of various quantities over the Jasper area
	bash WWKS22_Jasper_calc.sh
fi

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi

# Examine data and solutions along a profile from SW to NE across Jasper
# We adjust computed VGG and FAA up or down due to regional variations
function vgg_trend {	# $1 model
	# Improve fit of model to data by modeling a linear trend
	gmt math $1 T 35 50 DIV MUL 30 SUB ADD =
}
function vgg_trend2 {	# $1 model
	# Improve fit of model to data by modeling a linear trend
	gmt math $1 T 35 50 DIV MUL 7 SUB ADD =
}
function faa_trend {	# $1 model
	# Improve fit of model to data by modeling a linear trend
	gmt math $1 T 15 50 DIV MUL ADD 30 SUB =
}
function faa_trend2 {	# $1 model
	# Improve fit of model to data by modeling a linear trend
	gmt math $1 T 15 50 DIV MUL ADD 49 ADD =
}
function faa_trend3 {	# $1 model
	# Improve fit of model to data by modeling a linear trend
	gmt math $1 T 15 50 DIV MUL ADD 54 ADD =
}

# 1. Make the seamount and get mean density:
rho_w=1030
rho_l=$(gmt math -Q 2300 ${rho_w} SUB =)
rho_h=$(gmt math -Q 2900 ${rho_w} SUB =)
del_rho=$(gmt math -Q 2380 ${rho_w} SUB =)	# From Hammer et al, 1991
# Restrict the grid to just the edifice
gmt grdcut data/Jasper.grd -R-122:53/-122:33/30:17/30:37 -G/tmp/new.grd

# Make plots
gmt begin 
	gmt figure ${dir}WWKS22_Fig_Jasper $1
	gmt set FONT_TAG 16p MAP_FRAME_TYPE plain
	gmt subplot begin 3x1 -Fs20c/5c -A+o0.2c/-1.5c -M0
		gmt subplot set 2 -A"a)"
		gmt grdview /tmp/new.grd -JM12c -JZ3c -Qi -I+d -p110/20 -Cdem4 -Baf -Bzaf -BESltZ
		gmt subplot set 1 -A"b)"
		gmt makecpt -Cturbo -I -T2260/2620
		gmt plot3d -R-122:53/-122:33/30:17/30:37/-4100/0 -JM12c -JZ3c -p110/20 -C -So0.0197368421053c/0.0196473493335c+b calc/jasper_prisms_cut_dz.txt -i0:2,6,3  -Baf -Bzaf -BesltZ
		gmt colorbar -DjBC+w4c+o-2c/-4.75c -Bxaf -By+l"@~r@~" -p110/20 --MAP_FRAME_PEN=0.5p
		gmt subplot set 0 -A"c)"
		gmt makecpt -Cpolar -T-310/310/10 -H > t.cpt
		gmt grdmath calc/jasper_vgg_var.grd 12 SUB = t.grd
		gmt grdcontour t.grd -R-122:53/-122:33/30:17/30:37 -JM12c -p110/20 -Nt.cpt -S8 -C10 -A50 -Baf -Bzaf -BesltZ
		gmt grdtrack -Gcalc/jasper_vgg_var.grd -E-122:53/30:17/-122:33/30:37 | gmt plot -W1p,4_4:0 -JM12c -p110/20
	gmt subplot end

	gmt figure ${dir}WWKS22_Fig_profile $1
	w=-122.883573688
	e=-122.549802844
	s=30.283234081
	n=30.6170229022
	# Restrict the grid to just the edifice
	gmt grdcut @earth_vgg_01m -R-122:53/-122:33/30:17/30:37 -G/tmp/obs_vgg.grd
	gmt grdcut @earth_faa_01m -R-122:53/-122:33/30:17/30:37 -G/tmp/obs_faa.grd
	gmt subplot begin 3x1 -Fs16c/4.5c -A -Scb
		# VGG
		gmt basemap -R0/48/-50/280 -Bxaf+u" km" -Byaf+l"VGG (Eotvos)" -c
		gmt grdtrack -G/tmp/obs_vgg.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/vgg.txt
		gmt plot /tmp/vgg.txt -Sc4p -Gred -l"VGG v. 31"
		gmt grdtrack -Gcalc/jasper_vgg_var.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod1.txt
		vgg_trend /tmp/mod1.txt | gmt plot -W1p -l"Prisms"
		gmt grdtrack -Gcalc/jasper_vgg_fft_var_n2.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod2.txt
		vgg_trend2 /tmp/mod2.txt | gmt plot -W1p,blue -l"FFT (n = 2)"
		gmt grdtrack -Gcalc/jasper_vgg_fft_var_n8.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod3.txt
		vgg_trend2 /tmp/mod3.txt | gmt plot -W0.5p,orange -l"FFT (n = 8)"
		gmt grdtrack -Gcalc/jasper_vgg_fft_const_n8.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod3b.txt
		vgg_trend2 /tmp/mod3b.txt | gmt plot -W0.5p,cyan -l"FFT @~Dr@~ fixed"
		gmt math -T0/50/10 T 35 50 DIV MUL 35 SUB = | gmt plot -W0.5p,2_2:0 -l"Regional"
		echo "SW to NE" | gmt text -F+f10p+cTL+jTL -Dj6p/32p
		# FAA
		gmt basemap -R0/48/-30/120 -Bxaf+u" km" -Byaf+l"FAA (mGal)" -c
		gmt grdtrack -G/tmp/obs_faa.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/faa.txt
		gmt grdtrack -Gcalc/jasper_faa_var.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod4.txt
		gmt plot /tmp/faa.txt -Sc4p -Gred -l"FAA v. 31"
		faa_trend /tmp/mod4.txt | gmt plot -W1p -l"Prisms"
		gmt grdtrack -Gcalc/jasper_faa_fft_var_n2.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod5.txt
		faa_trend2 /tmp/mod5.txt | gmt plot -W1p,blue -l"FFT (n = 2)"
		gmt grdtrack -Gcalc/jasper_faa_fft_var_n8.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod6.txt
		faa_trend2 /tmp/mod6.txt | gmt plot -W0.5p,orange -l"FFT (n = 8)"
		gmt grdtrack -Gcalc/jasper_faa_fft_const_n8.grd -E${w}/${s}/${e}/${n}+d -o2,3 | grep -v NaN > /tmp/mod6b.txt
		faa_trend3 /tmp/mod6b.txt | gmt plot -W0.5p,cyan -l"FFT @~Dr@~ fixed"
		gmt math -T0/50/10 T 15 50 DIV MUL 25 SUB = | gmt plot -W0.5p,2_2:0 -l"Regional"
		echo "SW to NE" | gmt text -F+f10p+cTL+jTL -Dj6p/32p
		# TOPO
		gmt grdmath /tmp/new.grd 1000 DIV = /tmp/new_km.grd
		gmt grdtrack -G/tmp/new_km.grd -E${w}/${s}/${e}/${n}+d | gmt plot -i2,3 -L+yb -Ggray -l"Relief" -R0/48/-4.5/0 -c
		gmt math -T0/50/10 T 0.25 50 DIV MUL 4.27 SUB = | gmt plot -W0.5p,2_2:0 -l"Regional"
		echo "SW to NE" | gmt text -F+f10p+cTL+jTL -Dj6p/32p -Bxaf+u" km" -Byaf+l"Depth (km)" -BWsnr
	gmt subplot end
gmt end show
rm -f t.cpt t.grd
