: ------------------------------------------------------------------------------
:	 		  blueNOTE Regionalization Routine
:
: Author: Andrew Schreiber, Thomas Rutherford
: Date:   1/24/2018

: ------------------------------------------------------------------------------

: Environment variables:

@echo on

: Declare temporary directory which stores all intermediate .gdx files and .lst
: files.

set	temp=temp\

: Regionalization level (State or County). County option currently broken.

set	reg=State

: Sector aggregation scheme. Currently available: Energy disaggregation = eng.

set	agg=eng

: Dataset directory:

set	dsdir=datasets\

: ------------------------------------------------------------------------------
:	 	     Create directory structure for blueNOTE
: ------------------------------------------------------------------------------

: Need to create the directory structure using command line at some point.
: Note that the loadpoint directory is created within the calibrate.gms routine.

if not exist "%temp%nul"     mkdir "%temp%"
if not exist "%temp%gdx\nul" mkdir "%temp%gdx"
if not exist "%temp%lst\nul" mkdir "%temp%lst"
if not exist "%dsdir%nul"    mkdir "%dsdir%"

: ------------------------------------------------------------------------------
:	 	     Read and Calibrate National Tables
: ------------------------------------------------------------------------------

: Read in IO summary tables from the BEA website and output basic matrices and
: set definitions. Source: https://www.bea.gov/industry/io_annual.htm

:readbea
title	Reading National Tables
gams readbea.gms o="%temp%lst\readbea.lst"

: Shorten string identifiers:

:mapbea
title	Mapping national set identifiers
gams mapbea.gms o="%temp%lst\mapbea.lst"

: Form CGE parameters using raw input data:

:partbea
title	Partitioning national matrices into CGE parameters
gams partitionbea.gms o="%temp%lst\partitionbea.lst"

: Disaggregate sector accounts according to specified disaggration: 
:	- non -> No disaggregation
:	- agr -> Disaggregates agricultural sectors
:	- eng -> Disaggregates utilities and energy sectors
:	- tot -> Total disaggregation with exception to used and other goods. (currently broken)

:secdisagg
title	Disaggregating national parameters using 2007 tables
gams sectordisagg.gms --sectors=%agg% o="%temp%lst\sectordisagg.lst"

: Use matrix balancing to enforce accounting identities and verify benchmark
: with accounting CGE model called nationalmodel.gms for year %year%.
: Optimization methods provided:
:	- huber -> Hybrid huber loss function
:	- ls    -> Least squares
:	- ent	-> Entropy (not included)

:calibbea
title	Calibrating national tables to accounting model
gams calibrate.gms --sectors=%agg% --year=2014 --matbal=huber o="%temp%lst\calibrate.lst"

: Build tables for %reg% specification:

goto %reg%

: ------------------------------------------------------------------------------
:		     Regionalization (State Level)
: ------------------------------------------------------------------------------

:State

: Map national sets to non-numeric identifiers. nationalmodel.gms is used to
: verify consistency post mapping for year %year%.

:mapnat
title	Re-mapping national sectors to fit disaggregation
gams mapnat.gms --sectors=%agg% o="%temp%lst\mapnat.lst" --year=2014

: Regionalization is achieved through shares using GSP, CFS, GovExp, and PCE
: data. The following routines generate a set of consistent shares for use in
: disagg.gms. For a link to all regional sources:
: https://www.bea.gov/regional/downloadzip.cfm

: Produce a gams readable GSP dataset using stata. See
: Data\BEA\GDP\State\stategsp.do. Source:
: (https://www.bea.gov/newsreleases/regional/gdp_state/qgsp_newsrelease.htm)

:gsp
title	Reading GSP data and generting regional shares
gams readgsp.gms o="%temp%lst\readgsp.lst"
gams gspshare.gms --sectors=%agg% o="%temp%lst\gspshare.lst"

: Household expenditures follow the Personal Consumption Expenditure Survey
: data. Source: (https://www.bea.gov/newsreleases/regional/pce/pce_newsrelease.htm)

:pce
title	Reading PCE data and generting regional shares
gams readpce.gms o="%temp%lst\readpce.lst"
gams pceshare.gms --sectors=%agg% o="%temp%lst\pceshare.lst"

: Government expenditures are assumed to follow the state government finance tables.
: Source: (https://www.census.gov/programs-surveys/state/data/tables.All.html)

:govt
title	Reading SGF data and generting regional shares
gams readsgf.gms o="%temp%lst\readsgf.lst"
gams sgfshare.gms --sectors=%agg% o="%temp%lst\sgfshare.lst"

: Regional purchase coefficients which determine flows within and out to other
: states are generated through the 2012 commodity flow survey data. Source:
: (https://www.census.gov/econ/cfs/).

:cfs
title	Reading CFS data and generating regional purchase coefficients
gams readcfs.gms o="%temp%lst\readcfs.lst"
gams cfsshare.gms --sectors=%agg% o="%temp%lst\cfsshare.lst"

: Shares for exports are generated using Census data from USA Trade Online. The
: data is free, though an account is required to access the data. 
: Source: https://usatrade.census.gov/

:usatrade
title	Generating shares from USA Trade Online state import/export data
gams readusatrade.gms o="%temp%lst\readusatrade.gms"
gams usatradeshare.gms --sectors=%agg% o="%temp%lst\usatradeshr.lst"

: Disaggregate accounts by region and output a gdx file data for all years. The
: %year% environment variable determines the test year to verify benchmark
: consistency.

:regdisagg
title	Performing state level disaggregation
gams statedisagg.gms --year=2014 --sectors=%agg% o="%temp%lst\statedisagg.lst"

: OPTIONAL - we can think about enforcing certain identities following the
: output of the core blueNOTE dataset above. For instance, to pin down totals in
: energy sectors of the economic data which match SEDS. Note that additional
: data processing is required for SEDS data upstream. See data directories.
: Alternatively, set %calibto%=no if core blueNOTE accounts are of interest.
: The routine outputs data for a SINGLE year, defined by %year%.

:enforce
title	Calibrating state accounts to SEDS data and checking consistency
gams enforce.gms --year=2014 --calibto=seds --sectors=%agg% --matbal=ls o="%temp%lst\enforce.lst"
gams enforcechk.gms --year=2014 --calibto=seds --sectors=%agg% o="%temp%lst\enforcechk.lst"
