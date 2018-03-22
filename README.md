# blueNOTE: **N**ational **O**pen source **T**ools for general **E**quilibrium analysis

A byproduct of a recently completed research project conducted with G&ouml;kce
Akin-Olcum (from Environmental Defense Fund) and Christoph B&ouml;hringer (from
the University of Oldenburg) is an open-source dataset suitable for analysis of
energy-economy-environment issues in North America. We begin with the national
input-output table and downscale to the county level using regional economic
statistics from the Bureau of Economic Analysis. We also employ data from
Census Bureaus (foreign trade statistics) and International Trade
Administration for bilateral trade statistics. Input-output tables will further
be complemented by physical energy quantities and energy prices from the
Department of Energys State Energy Data System (SEDS) of EIA.

We call the utilities for producing our dataset blueNOTE. blueNOTE is a
collection of GAMS and Stata program for producing subnational economic
accounts for input-output or computable general equilibrium models of the
United States economy. All code and data necessary for producing subnational
accounts are provided in this repository. Currently, the routine can produce
state level accounts.

## Getting Started ##

You can peruse the build routine files in the Build directory. These include
all GAMS programs and defines files for sets and mappings. You may download the
full build including the intermediate data files from
[here](https://aae.wisc.edu/BlueNOTE/build/build.zip) (88 MB). Source data files can
be downloaded from
our
[Box Repository](https://uwmadison.box.com/s/3pazisdjxc80gu12kdx7hke6tvno7tpz).

Be sure to unzip the data files into the Data directory. Note that all data
sources are provided in the batch file. Included in the data download are both
pre-processed and processed data files. All code needed for reconciliation
(GAMS and Stata) are included. The downloaded data files do not need to be
altered and will work as is. While Stata was used to process data files, GAMS
is the primary language we use to generate the dataset. Post processed GDX
files are available for users not familiar with Stata.

## Documentation Coming Soon ##

For the time being, the best overview of the build stream
is
[run.bat](https://github.com/drewschreiber/blueNOTE/blob/master/Build/run.bat).
