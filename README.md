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

## Documentation Coming Soon ##

For the time being, the best overview of the build stream
is
[run.bat](https://github.com/drewschreiber/blueNOTE/blob/master/Build/run.bat).

## Acknowledgements ##

bluNOTE is written by Andrew Schreiber and Thomas F. Rutherford with
affiliations to the [Department of Agricultural and Applied
Economics](https://www.aae.wisc.edu) at the [University of
Wisconsin-Madison](https://www.wisc.edu) and the [Wisconsin Institute for
Discovery](https://www.wid.wisc.edu). Funding is gratefully acknowledged by the
[Environmental Defense Fund](https://www.edf.org).