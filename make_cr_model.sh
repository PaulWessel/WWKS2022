#!/usr/bin/env -S bash -e
# This script helps create several files:
#
# CR1984_model.txt		Carlson & Raskin, 1984
# B2005_model.txt		Broucher, 2005
#
# These are used in WWKS22_Fig_vp-rho-model.sh to show the
# predicted density models.  They are all deleted once used.
# The model file is depth vs rho, while conf is 1-sigma envelope.
#

# Lookup table from Brocher (2005)
V2R=data/Brocher-2005-rho-v.txt
# Wipe any existing files
rm -f CR1984_model.txt B2005_model.txt
rm -f CR1984_conf.txt B2005_conf.txt CR1984_zrw.txt

while read z vp vp_conf; do
	# Get low and high velocities
	vp_l=$(gmt math -Q $vp $vp_conf SUB =)
	vp_h=$(gmt math -Q $vp $vp_conf ADD =)
	# Compute CR84 values
	r_m=$(gmt math -Q 3.50 3.79 $vp   DIV SUB =)
	r_l=$(gmt math -Q 3.50 3.79 $vp_l DIV SUB =)
	r_h=$(gmt math -Q 3.50 3.79 $vp_h DIV SUB =)
	d_r=$(gmt math -Q $r_h $r_l SUB 2 DIV =)
	echo "$z	$r_m" >> CR1984_model.txt
	echo "$z	$r_l" >> CR1984_conf.txt
	echo "$z	$r_h" >> /tmp/a.txt
	echo "$z	$r_m	$d_r" >> CR1984_zrw.txt
	# Sample B2005 values
	r_m=$(gmt sample1d ${V2R} -T${vp},   -o1)
	r_l=$(gmt sample1d ${V2R} -T${vp_l}, -o1)
	r_h=$(gmt sample1d ${V2R} -T${vp_h}, -o1)
	echo "$z	$r_m" >> B2005_model.txt
	echo "$z	$r_l" >> B2005_conf.txt
	echo "$z	$r_h" >> /tmp/b.txt
done < median_v.txt
gmt convert -I /tmp/a.txt >> CR1984_conf.txt
gmt convert -I /tmp/b.txt >> B2005_conf.txt
