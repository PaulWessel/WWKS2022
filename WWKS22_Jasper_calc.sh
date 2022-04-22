#!/bin/bash
# Support script for Jasper seamount density structure and gravity anomaly
# We compute grids of various quantities over the Jasper area
# It will be run (and takes 45 minutes) if the calc directory is missing

mkdir -p calc

# 1. Make the seamount and get mean density:
rho_w=1030
rho_l=$(gmt math -Q 2300 ${rho_w} SUB =)
rho_h=$(gmt math -Q 2900 ${rho_w} SUB =)
del_rho=$(gmt math -Q 2380 ${rho_w} SUB =)	# From Hammer et al, 1991
# Restrict the grid to just the edifice
gmt grdcut data/Jasper.grd -R-122:53/-122:33/30:17/30:37 -G/tmp/new.grd
# Create a mask to chop off a quadrant with a vertex at the summit
cat << EOF > /tmp/mask.txt
-122.733459288	30.283234081
-122.733459288	30.4439647776
-122.549802844	30.4439647776
-122.549802844	30.283234081
EOF
# Make a smooth version of topo we can use as h(x,y)
gmt grdfilter /tmp/new.grd -Fg5 -G/tmp/smooth_h.grd -D2
# Make variable prism densities for the grid with the missing quadrant (used for plot3d)
# Mask the data, and let the missing part stay at -4100 m
gmt grdmask /tmp/mask.txt -R/tmp/new.grd -N1/1/NaN -G/tmp/mask.grd
gmt grdmath /tmp/new.grd /tmp/mask.grd MUL -4100 DENAN = /tmp/cut.grd
gmt gravprisms -S/tmp/smooth_h.grd -C+q+wcalc/jasper_prisms_cut_dz.txt+z100 -L-4100 -fg -H7000/2300/2900 -T/tmp/cut.grd
## Make constant and variable prisms densities for gravity modeling
gmt gravprisms -S/tmp/smooth_h.grd -C+q+wcalc/jasper_prisms_dz.txt+z100 -L-4100 -fg -H7000/${rho_l}/${rho_h} -T/tmp/new.grd -W/tmp/jasper_ave_dens.grd
gmt gravprisms -S/tmp/smooth_h.grd -C+q+wcalc/jasper_prisms.txt -L-4100 -fg -D${del_rho} -T/tmp/new.grd
# Compute VGG on a coarser grid
gmt gravprisms -R-122:53/-122:33/30:17/30:37 -I15s -fg calc/jasper_prisms.txt -Fv -Gcalc/jasper_vgg_const.grd -V
gmt gravprisms -R-122:53/-122:33/30:17/30:37 -I30s -fg calc/jasper_prisms.txt -Ff -Gcalc/jasper_faa_const.grd -V
gmt gravprisms -R-122:53/-122:33/30:17/30:37 -I15s -fg calc/jasper_prisms_dz.txt -Fv -Gcalc/jasper_vgg_var.grd -V
gmt gravprisms -R-122:53/-122:33/30:17/30:37 -I30s -fg calc/jasper_prisms_dz.txt -Ff -Gcalc/jasper_faa_var.grd -V
gmt gravfft /tmp/new.grd -D/tmp/jasper_ave_dens.grd -Fv -E2 -Gcalc/jasper_vgg_fft_var_n2.grd -V
gmt gravfft /tmp/new.grd -D/tmp/jasper_ave_dens.grd -Fv -E8 -Gcalc/jasper_vgg_fft_var_n8.grd -V
gmt gravfft /tmp/new.grd -D${del_rho} -Fv -E2 -Gcalc/jasper_vgg_fft_const_n2.grd -V
gmt gravfft /tmp/new.grd -D/tmp/jasper_ave_dens.grd -Ff -E2 -Gcalc/jasper_faa_fft_var_n2.grd -V
gmt gravfft /tmp/new.grd -D/tmp/jasper_ave_dens.grd -Ff -E8 -Gcalc/jasper_faa_fft_var_n8.grd -V
gmt gravfft /tmp/new.grd -D${del_rho} -Ff -E2 -Gcalc/jasper_faa_fft_const_n2.grd -V
gmt gravfft /tmp/new.grd -D1350 -Fv -E8 -Gcalc/jasper_vgg_fft_const_n8.grd -V
gmt gravfft /tmp/new.grd -D1350 -Ff -E8 -Gcalc/jasper_faa_fft_const_n8.grd -V

# Remove temp grids and files
rm -f /tmp/mask.txt /tmp/mask.grd /tmp/cut.grd /tmp/smooth_h.grd /tmp/jasper_ave_dens.grd /tmp/new.grd
