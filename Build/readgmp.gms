$stitle Program for reading GMP data

* Use CSV2GDX to convert the GMP data into a gams readable format. Before
* doing that, remove intermittent lines of text in CSV file.

* Lines that need to be deleted:

* "Note: See the included footnote file."
* NAICS Industry detail is based on the 2007 North American Industry Classification System (NAICS).
* "Source: U.S. Department of Commerce / Bureau of Economic Analysis / Regional Product Division"
* "GeoFIPS","GeoName","Region","ComponentId","ComponentName","IndustryId","IndustryClassification","Description","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015"

$call 'findstr /v /i /c:"Note:" /c:"NAICS" /c:"Source" /c:"GeoFIPS" "..\Data\BEA\GDP\Metro\allgmp.csv" >"..\Data\BEA\GDP\Metro\allgmp_recon.csv"'
$call 'csv2gdx ..\Data\BEA\GDP\Metro\allgmp_recon.csv output=..\Data\BEA\GDP\Metro\allgmp_recon.gdx id=gmp_all_ useheader=y ColCount=23 index=(1..8) value=(9..LastCol)'

set	mf	Metro fips codes,
	mn	Metro names,
	mr	Metro region,
	ctc	Category code,
	ctn	Category name,
	iid	Industry ID,
	icl	Industry classification,
	ids	Industry description,
	ust	US Totals;

$gdxin "..\Data\BEA\GDP\Metro\allgmp_recon.gdx"
$loaddc mf=Dim1 mn=Dim2 mr=Dim3 ctc=Dim4 ctn=Dim5
$loaddc iid=Dim6 icl=Dim7 ids=Dim8 ust=Dim9

* Hard code years for now -- not sure why ColCount failed.

set	yr		Years /1997*2015/,
	mapyr(yr,ust)	Mapping between years and US Totals;

mapyr(yr,ust) = yes$(ord(yr) = ord(ust));

parameter	gmp_all_(mf,mn,mr,ctc,ctn,iid,icl,ids,ust)	Gross state product database,
		gmp_all(mf,mn,mr,ctc,ctn,iid,icl,ids,yr)	Mapped gross state produce database;

$onUNDF
$loaddc gmp_all_
gmp_all_(mf,mn,mr,ctc,ctn,iid,icl,ids,ust)$(gmp_all_(mf,mn,mr,ctc,ctn,iid,icl,ids,ust) = UNDF) = 0;
$offUNDF

gmp_all(mf,mn,mr,ctc,ctn,iid,icl,ids,yr) = sum(mapyr(yr,ust), gmp_all_(mf,mn,mr,ctc,ctn,iid,icl,ids,ust));

set	in(mf,mn,mr,ctc,ctn,iid,icl,ids,yr)		Used set tuples;
option 	in<gmp_all;

* Lose the superfluous descriptive columns:

parameter	gmp_(mf,yr,ctc,iid)	Trimmed GMP data;

gmp_(mf,yr,ctc,iid) = sum(in(mf,mn,mr,ctc,ctn,iid,icl,ids,yr), gmp_all(mf,mn,mr,ctc,ctn,iid,icl,ids,yr));

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
	gdpmap(gdpcat,ctc)	Mapping between category names
				/ gdp.200, qty.800, rgdp.900 /;

parameter	gmp(mf,yr,gdpcat,iid)	Mapped state level annual GDP;

loop(gdpmap(gdpcat,ctc),
	gmp(mf,yr,gdpcat,iid) = gmp_(mf,yr,ctc,iid));

execute_unload 'temp\gdx\gmp_raw.gdx' gmp,mf,gdpcat,yr,iid=s;