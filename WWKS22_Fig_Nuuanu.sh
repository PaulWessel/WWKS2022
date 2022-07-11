#!/usr/bin/env bash
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Fig:	Nuuanu 3-D views
#
# P. Wessel, April 2022
# Double-column figure in GJI so aim for W <= 17.3 cm

# Determine if we need to specify an output directory or not
if [ "X${1}" = "X" ]; then
	dir=
else
	dir="${1}/"
fi
R=-R158.35W/156.25W/21.25N/23.2N
m=c
f=0.1
water=-5300
dx=0.001
#Slide=-S+a-20/120+h750/6000+d750+u0.05+p10
Slide=-S+a-20/120+h750/6000+d300+v20+p10
# Flexure due to redistribution
echo 157.85W 21.55N 50 7000 > /tmp/oahu.txt
gmt grdseamount -R161W/154:30W/18:30N/25N -I0.01 /tmp/oahu.txt -C${m} -F${f} -G/tmp/before.nc
gmt grdseamount -R161W/154:30W/18:30N/25N -I0.01 /tmp/oahu.txt -C${m} -F${f} -G/tmp/after.nc ${Slide}
gmt grdmath /tmp/after.nc /tmp/before.nc SUB = /tmp/load.nc
gmt grdflexure /tmp/load.nc -E25k -D3300/2650/1030 -G/tmp/flex.nc 
gmt begin ${dir}WWKS22_Fig_Nuuanu $1
	gmt set GMT_GRAPHICS_DPU 600i FONT_ANNOT_PRIMARY 14p
	gmt makecpt -Cgeo -T-10000/2000
	#gmt grdcut $R /Users/pwessel/Downloads/mhi_mbsyn_bathytopo_50m_v21.nc -Gdata/oahu_dem.nc
	#gmt grdcut @earth_relief_15s $R -Gdata/oahu_dem.nc
	gmt grdview data/oahu_dem.nc -Qi -I+a70 -p50/20 -JZ2c -Y18c -B -N+glightgray
	gmt colorbar -DJTC+r -Bxaf -By -p
	# Nuuanu simulation
	gmt grdseamount $R -I${dx} /tmp/oahu.txt -C${m} -F${f} -Z${water} -G/tmp/oahu_pre_slide.nc
	gmt grdseamount $R -I${dx} /tmp/oahu.txt -C${m} -F${f} -Z${water} -G/tmp/oahu_post_slide.nc ${Slide} -V
	gmt grdview /tmp/oahu_post_slide.nc -Qi -I+a70 -p -JZ2c -Y-8c -B -Wc0.25p
	gmt colorbar -DJTC+r -Bxaf -By -p
	# Flexure figure
	gmt makecpt -Cpolar+h -T-3500/700 -H > t.cpt
	gmt grdimage $R /tmp/load.nc -p50/20 -Y-8c -Ct.cpt -B
	gmt grdcontour $R /tmp/flex.nc -C10 -A20 -p -GlZ+/155:30W/21:30N
	gmt colorbar -DJTC+r -Bxaf -By -p -Ct.cpt
	gmt text -R0/15/0/25 -Jx1c -F+f18p -N <<- EOF
	0	7	c)
	0	16	b)
	0	24	a)
	EOF
gmt end show
rm -f /tmp/before.nc /tmp/after.nc /tmp/load.nc /tmp/flex.nc /tmp/oahu_pre_slide.nc
rm -f /tmp/oahu_post_slide.nc t.cpt /tmp/oahu.txt
