#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Gaussian seamount (truncated) in 3D showing the three density models:
# 		(a) constant density, (b) full variable density, and (c) variable horizontal density.
#
# P. Wessel, April 2022

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi

# 1. Make the seamount, then remove one quadrant:
echo "0 0 30 6" | gmt grdseamount -R-30/30/-30/30 -I0.2 -r -G/tmp/prismfig_smt.grd -Cg -F0.2 -H7/2400/3030+p0.8 -W/tmp/prismfig_averho.grd
gmt grdmath /tmp/prismfig_smt.grd 1 X 0 LT Y 0 LT MUL SUB MUL = /tmp/prismfig_smt.grd
rho_l=$(gmt grdinfo /tmp/prismfig_averho.grd | grep Remark | awk '{print $NF}')
# 1a. Make the constant density prisms
gmt gravprisms -S/tmp/prismfig_smt.grd -D${rho_l} -C+w/tmp/prismfig_prisms1.txt+q
# 1b. Make variable constant prism densities
gmt gravprisms -S/tmp/prismfig_smt.grd -D/tmp/prismfig_averho.grd -C+w/tmp/prismfig_prisms2.txt+q
# 1c. Make variable prism densities
gmt gravprisms -S/tmp/prismfig_smt.grd -H7/2400/3030+p0.8 -C+w/tmp/prismfig_prisms3.txt+q+z0.2
# Make plots
gmt begin ${dir}WWKS22_Fig_prisms $1
	gmt set FONT_TAG 16p
 	gmt makecpt -Cturbo -I -T2400/2950
	gmt subplot begin 3x1 -Fs10c/4c -A+o0.2c/-1.3c -M1p
		gmt subplot set 0
		gmt plot3d -R-30/30/-30/30/0/7 -JX8c -JZ3c -C -So1q+b /tmp/prismfig_prisms1.txt -i0:2,6,3 -Baf -Bzaf -BWSrtZ -p200/20
		echo "@~r@~@-l@-" | gmt text -F+f12p,Times-Italic+cBR+jBR -N -D0/4c
		gmt subplot set 2
		gmt plot3d -R-30/30/-30/30/0/7 -JX8c -JZ3c -C -So1q+b /tmp/prismfig_prisms2.txt -i0:2,6,3 -Baf -Bzaf -BWSrtZ -p200/20
		echo "@~r@~@-l@-(r)" | gmt text -F+f12p,Times-Italic+cBR+jBR -N -D0/4c
		gmt subplot set 1
		gmt plot3d -R-30/30/-30/30/0/7 -JX8c -JZ3c -C -So1q+b /tmp/prismfig_prisms3.txt -i0:2,6,3 -Baf -Bzaf -BWSrtZ -p200/20
		echo "@~r@~@-l@-(r,z)" | gmt text -F+f12p,Times-Italic+cBR+jBR -N -D0/4c
	gmt subplot end
	gmt colorbar -DJBC -Bxaf -By+l"kg\267m@+-3@+"
gmt end show
rm -f gmt.history
