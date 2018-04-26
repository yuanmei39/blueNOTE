# blueNOTE: **N**ational **O**pen source **T**ools for general **E**quilibrium analysis

A byproduct of a recently completed research project conducted with
G&ouml;k&ccedil;e Akin-Ol&ccedil;um (from Environmental Defense Fund) and
Christoph B&ouml;hringer (from the University of Oldenburg) is an open-source
dataset suitable for analysis of energy-economy-environment issues in North
America. We begin with the Bureau of Economic Analysis' (BEA) [national
input-output table](https://www.bea.gov/industry/io_annual.htm) and downscale
to the regional level using publicly available economic statistics from
governmental agencies. We use additional data from the BEA on regional [gross
product](https://www.bea.gov/newsreleases/regional/gdp_state/qgsp_newsrelease.htm)
and [consumer
expenditures](https://www.bea.gov/newsreleases/regional/pce/pce_newsrelease.htm)
and data from the Census Bureau on [foreign
trade](https://usatrade.census.gov), [bilateral
trade](https://www.census.gov/econ/cfs/) and [state government
expenditures](https://www.census.gov/programs-surveys/state/data/tables.All.html). Input-output
tables can further be complemented by physical energy quantities and energy
prices from the Department of Energy's [State Energy Data System
(SEDS)](https://www.eia.gov/state/seds/) of EIA.

We call the utilities for producing our dataset blueNOTE. blueNOTE is a
collection of [GAMS](https://www.gams.com/) (General Algebraic Modeling System)
programs for producing subnational economic accounts for input-output or
computable general equilibrium models of the United States economy. All code
and data necessary for producing subnational accounts are provided in this
repository. Currently, the routine can produce state level accounts.

## Getting Started ##

You can peruse the build routine files in the Build directory. These include
all GAMS programs and defines files for sets and mappings. You may download the
full build including the intermediate data files from
[here](https://aae.wisc.edu/BlueNOTE/build/build.zip) (88 MB). Source data
files can be downloaded from our [Box
Repository](https://uwmadison.box.com/s/3pazisdjxc80gu12kdx7hke6tvno7tpz).

Be sure to unzip the data files into the Data directory. Note that all data
sources are provided in the batch file. Included in the data download are both
pre-processed and processed data files. All code needed for reconciliation are
included. The downloaded data files do not need to be altered and will work as
is.

## Documentation ##

See our [webpage](https://aae.wisc.edu/BlueNOTE).

The paper for blueNOTE can be
downloaded [here](https://aae.wisc.edu/BlueNOTE/blueNOTE.pdf).

In this paper, we describe the computer programs used to construct regional
social accounting matrices and a canonical calibrated static multi-regional,
multi-sectoral computable general equilibrium (CGE) model which complements the
constructed set of data. The modeling framework is intended to be used as a
foundational structure from which an empirical model for policy analysis can be
based upon. We focus on the development of state level economic data and show
how to extend the core build stream to incorporate additional energy satellite
data for formulating an energy based CGE model. The energy based CGE model is
used to calculate carbon leakage rates given diferent regional configurations
of state level action in restricting emission levels. In this calculation, we
explore result sensitivity from including gravity based state level bilateral
trade flows relative to a model calibrated with a pooled national market.

Another concise overview of the build stream is the launching
program,
[run.bat](https://github.com/drewschreiber/blueNOTE/blob/master/Build/run.bat).

## Acknowledgements ##

bluNOTE is written by Andrew Schreiber and Thomas F. Rutherford with
affiliations to the [Department of Agricultural and Applied
Economics](https://www.aae.wisc.edu) at the [University of
Wisconsin-Madison](https://www.wisc.edu) and the [Wisconsin Institute for
Discovery](https://www.wid.wisc.edu). Funding is gratefully acknowledged by the
[Environmental Defense Fund](https://www.edf.org).
