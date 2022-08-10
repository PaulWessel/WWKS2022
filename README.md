# LaTeX and GMT script sources for Wessel et al (2022)

This folder contains all the files needed to build the PDF and PNG versions of the
GMT illustrations as well as the manuscript using LaTeX: one for the preprint and
another one for submitting *Geophysical Journal International*.
The two main LaTeX documents are:

- `WWKS22_preprint.tex`: for building the preprint
- `WWKS22.tex`: for building the manuscript using the GJI template

These two files only contain a header and some configurations, but the content
of the article is split in separate files, which are then imported directly
into `WWKS22_preprint.tex` and `WWKS22.tex`.
The extra files are:

- `WWKS22_abstract.tex`: contains the text for the abstract
- `WWKS22_content.tex`: contains the body of the paper, with sections, figures,
    equations, etc.
- `WWKS22_appendix.tex`: contains the appendix.
- `WWKS22variables.tex`: defines some variables that contain additional information
    like the title of the manuscript, information about the authors, keywords
    and more.

The information about the references can be found inside `WWKS22_refs.bib`,
while the bibliography styles used for the preprint and the submission
manuscript are inside `apalike-doi.bst` and `gji.bst`, respectively.

This folder also contains the files provided by GJI to build the manuscript
using their template (`gji.cls`, `gji_extra.sty` and `times.sty`).

The figures of the article can are built by GMT and will be written
to the pdf and png directories. They are created by the Makefile and
may use the data in the data directory.

## How to build the manuscript

In order to build the manuscript, you need to install a LaTeX distribution and
the `pdflatex` tool.

The `Makefile` has rules for building the PDF of the manuscript; try
make help for details.

To build all the PDF figures, run:

```
make pdf
```

To build all the PNG figures, run:

```
make ong
```

To build the preprint PDF, run:

```
make preprint
```

To build the PDF of the submission manuscript, run:

```
make paper
```

You can also ask for a word and figures count using:

```
make word-count
```
