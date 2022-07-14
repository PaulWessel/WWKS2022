#
# Makefile for
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamounts, Geophys. J. Int.
#
# Extra texlive packages needed on Macports to run this
# texlive-bibtex-extra texlive-latex-extra texlive-pictures texlive-plain-generic
#
# LaTeX command
PDFLATEX=pdflatex

help::
		@grep '^#!' Makefile | cut -c3-
#!-------------------- MAKE HELP FOR PAPER --------------------
#!
#!
#!make <target>, where <target> can be:
#!
#!archive       : Build zip file with Latex contents
#!recalc        : Remove the calc directory to recompute Jasper grids
#!paper         : Build figures and then PDF for the paper
#!pdf           : Just build or update PDF figures for the paper
#!png           : Just build or update PNG figures for the paper
#!jpg           : Just build or update JPG figures for the paper
#!clean         : Clean up and remove created Latex files of all types, except figs and calc
#!spotless      : As clean, but also delete all created PDF, JPG and PNG figures
#!wipe          : As spotless, but also delete the calc directory
#!
#---------------------------------------------------------------------------
FIG=	WWKS22_Fig_01.sh WWKS22_Fig_02.sh WWKS22_Fig_03.sh \
		WWKS22_Fig_04.sh WWKS22_Fig_05.sh WWKS22_Fig_06.sh \
		WWKS22_Fig_07.sh WWKS22_Fig_08.sh WWKS22_Fig_09.sh \
		WWKS22_Fig_10.sh WWKS22_Fig_11.sh WWKS22_Fig_12.sh \
		WWKS22_Fig_13.sh WWKS22_Fig_14.sh WWKS22_Fig_15.sh \
		WWKS22_Fig_16.sh

# Note: WWKS22_Fig_15.sh starts from scratch and takes 40 minutes to
#		complete if you delete the calc directory after it already exists

PDFtmp= $(FIG:.sh=.pdf)
PDF= $(addprefix pdf/, $(PDFtmp))
PNGtmp= $(FIG:.sh=.png)
PNG= $(addprefix png/, $(PNGtmp))
JPGtmp= $(FIG:.sh=.jpg)
JPG= $(addprefix jpg/, $(JPGtmp))

paper:	WWKS22.pdf pdf png jpg
		open WWKS22.pdf

png:	$(PNG)

pdf:	$(PDF)

jpg:	$(JPG)

jpg/%.jpg: %.sh
	bash $*.sh jpg; rm -f gmt.conf gmt.history

png/%.png: %.sh
	bash $*.sh png; rm -f gmt.conf gmt.history

pdf/%.pdf: %.sh
	bash $*.sh pdf; rm -f gmt.conf gmt.history

WWKS22_Fig_15.sh:	WWKS22_Jasper_calc.sh
WWKS22_Fig_16.sh:	WWKS22_Jasper_calc.sh

.FORCE:

WWKS22.pdf: pdf WWKS22.tex WWKS22_abstract.tex WWKS22_appendix.tex WWKS22_content.tex WWKS22_variables.tex
	\rm -f WWKS22*.{aux,idx,ilg,ind,log,lof,lot,toc,out,dvi}
	$(PDFLATEX) WWKS22
	bibtex WWKS22
	$(PDFLATEX) WWKS22
	$(PDFLATEX) WWKS22

recalc:
	rm -rf calc

clean:
	rm -f WWKS22*.{aux,idx,ilg,blg,bbl,ind,log,lof,lot,toc,out,dvi}

spotless:	clean
	rm -f WWKS22_Fig_*.png WWKS22_Fig_*.jpg WWKS22_Fig_*.pdf WWKS22.pdf gmt.history
	rm -rf png pdf jpg

wipe:	spotless
	rm -rf calc

archive:
	COPYFILE_DISABLE=1 tar cvf WWKS22.tar *.tex *.bib natbibspacing.sty \
	orcidlink.sty gji.bst gji.cls gji_extra.sty timet.sty apalike-doi.bst \
	pdf/WWKS22_Fig_0?.pdf pdf/WWKS22_Fig_1[1236].pdf jpg/WWKS22_Fig_1[045].jpg
