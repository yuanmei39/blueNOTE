$title Share Generation Based On State Level Gross Product

$ontext
See Data directory for stata code on reading GSP data (see
stategdp.do). Suppress shares for 2015 due to data inavailability.
$offtext

* -------------------------------------------------------------------------
* 	Read in the data from Data directory:
* -------------------------------------------------------------------------

set	yr /1997*2015/;

set	st	Regions /
$include defines\stategsp.set
/,
	s	Industry list /
$include defines\sectorsgsp.set
/,
	com	Components of GDP /
$include defines\componentgsp.set
/;

parameter	gsp_(st,yr,com,s)	State level annual GDP;

$call 'gdxxrw.exe i=..\Data\BEA\GDP\State\gsp.xlsx o=temp\gdx\gspdata.gdx par=gsp_ rng=gsp! rdim=4 cdim=0'
$gdxin 'temp\gdx\gspdata.gdx'
$loaddc gsp_

* -------------------------------------------------------------------------
* 	Map indices to match national files and eliminate numeric sets:
* -------------------------------------------------------------------------

set 	gdpcat 	GDP category names/
		gdp	"Gross domestic product (GDP) by state"
		taxsbd	"Taxes on production and imports less subsidies"
		cmp	"Compensation of employees"
		sbd	"Subsidies"
		tax	"Taxes on production and imports"
		gos	"Gross operating surplus"
		qty	"Quantity indexes for real GDP by state"
		rgdp	"Real GDP by state"
		perc	"Per capita real GDP by state" /,
	gdpmap(gdpcat,com)	Mapping between category names
				/ gdp.200, taxsbd.300, cmp.400, sbd.500,tax.600
				  gos.700, qty.800, rgdp.900, perc.1000 /;


* Map to state abbreviations instead of FIPS codes and non-numeric
* sectoring detail:

set	r		State abbreviations /
$include 'defines\states.set'
/,
	map(st,r)	Mapping to state abbreviations /
$include 'defines\statefipsmap.map'
/;

parameter	gsp(r,yr,gdpcat,s)	Mapped state level annual GDP;

loop(gdpmap(gdpcat,com),
	gsp(r,yr,gdpcat,s) = sum(map(st,r), gsp_(st,yr,com,s)););

execute_unload 'temp\gdx\gsp_raw.gdx',gsp,yr,r,s,gdpcat;
