#!/usr/bin/env -S bash -e
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig 15:	Jasper seamount 3-D view density structure and gravity anomaly
#
# P. Wessel, April 2022

if [ -d calc ]; then	# Nothing to do
	echo "WWKS22_Fig_15: Directory calc exist so we will reuse those results."
	echo "WWKS22_Fig_15: Delete the calc directory if you want to start fresh."
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
gmt begin ${dir}WWKS22_Fig_15 $1 E600
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
gmt end show
rm -f t.cpt t.grd
