#
# GNU Makefile for
#
# Wessel, P., Watts, A. B., Kim, S.-S., and Sandwell, D. T., 2022
#   Models for the Evolution of Seamount, Geophys. J. Int.
#
# Extra texlive packages needed on Macports to run this
# texlive-bibtex-extra texlive-latex-extra texlive-pictures texlive-plain-generic
#
# LaTeX command
PDFLATEX=pdflatex

help::
		@grep '^#!' GNUmakefile | cut -c3-
#!-------------------- MAKE HELP FOR PAPER --------------------
#!
#!
#!make <target>, where <target> can be:
#!
#!recalc        : Remove the calc directory to recompute Jasper grids
#!paper         : Build figures and then PDF for the paper
#!pdf           : Just build or update PDF figures for the paper
#!png           : Just build or update PNG figures for the paper
#!clean         : Clean up and remove created files of all types, except calc
#!spotless      : As clean, but also delete all created PDF and PNG figures
#!wipe          : As spotless, but also delete the calc directory
#!
#---------------------------------------------------------------------------
FIG=	WWKS22_Fig_Gaussian.sh WWKS22_Fig_cone.sh WWKS22_Fig_disc.sh \
		WWKS22_Fig_parabola.sh WWKS22_Fig_flux.sh WWKS22_Fig_increments.sh \
		WWKS22_Fig_vp-rho.sh WWKS22_Fig_vp-rho-model.sh WWKS22_Fig_polynomial.sh \
		WWKS22_Fig_smt.sh WWKS22_Fig_densitymodel.sh WWKS22_Fig_slide.sh \
		WWKS22_Fig_Nuuanu.sh WWKS22_Fig_Jasper.sh WWKS22_Fig_prisms.sh

# Note: WWKS22_Fig_Jasper.sh starts from scratch and takes 40 minutes to
#		complete if you delete the calc directory after it already exists

PDFtmp= $(FIG:.sh=.pdf)
PDF= $(addprefix pdf/, $(PDFtmp))
PNGtmp= $(FIG:.sh=.png)
PNG= $(addprefix png/, $(PNGtmp))

paper:	WWKS22.pdf pdf png
		open WWKS22.pdf

png:	$(PNG)

pdf:	$(PDF)

png/%.png: %.sh
	bash $*.sh png; rm -f gmt.conf gmt.history

pdf/%.pdf: %.sh
	bash $*.sh pdf; rm -f gmt.conf gmt.history

WWKS22_Fig_Jasper.sh:	WWKS22_Jasper_calc.sh

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
	rm -f WWKS22_Fig_*.png WWKS22_Fig_*.pdf WWKS22.pdf gmt.history
	rm -rf png pdf

wipe:	spotless
	rm -rf calc
