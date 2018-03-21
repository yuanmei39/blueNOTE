$stitle Program for reading GSP data

* Use CSV2GDX to convert the GSP data into a gams readable format. Before
* doing that, remove intermittent lines of text in CSV file.

* Lines that need to be deleted:

* "Note: See the included footnote file."
* NAICS Industry detail is based on the 2007 North American Industry Classification System (NAICS).
* "Source: U.S. Department of Commerce / Bureau of Economic Analysis / Regional Product Division"
* "GeoFIPS","GeoName","Region","ComponentId","ComponentName","IndustryId","IndustryClassification","Description","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015"

$call 'findstr /v /i /c:"Note:" /c:"NAICS" /c:"Source" /c:"GeoFIPS" "..\Data\BEA\GDP\State\gsp_naics_all.csv" >"..\Data\BEA\GDP\State\gsp_naics_recon.csv"'
$call 'csv2gdx ..\Data\BEA\GDP\State\gsp_naics_recon.csv output=..\Data\BEA\GDP\State\gsp_naics_recon.gdx id=gsp_all_ useheader=y ColCount=27 index=(1..8) value=(9..LastCol)'

set	stf	State fips codes,
	stn	State names,
	str	State region,
	ctc	Category code,
	ctn	Category name,
	iid	Industry ID,
	icl	Industry classification,
	ids	Industry description,
	ust	US Totals;

$gdxin "..\Data\BEA\GDP\State\gsp_naics_recon.gdx"
$loaddc stf=Dim1 stn=Dim2 str=Dim3 ctc=Dim4 ctn=Dim5
$loaddc iid=Dim6 icl=Dim7 ids=Dim8 ust=Dim9

* Hard code years for now -- not sure why ColCount failed.

set	yr		Years /1997*2015/,
	mapyr(yr,ust)	Mapping between years and US Totals;

mapyr(yr,ust) = yes$(ord(yr) = ord(ust));

parameter	gsp_all_(stf,stn,str,ctc,ctn,iid,icl,ids,ust)	Gross state product database,
		gsp_all(stf,stn,str,ctc,ctn,iid,icl,ids,yr)	Mapped gross state produce database;

$onUNDF
$loaddc gsp_all_
gsp_all_(stf,stn,str,ctc,ctn,iid,icl,ids,ust)$(gsp_all_(stf,stn,str,ctc,ctn,iid,icl,ids,ust) = UNDF) = 0;
$offUNDF

gsp_all(stf,stn,str,ctc,ctn,iid,icl,ids,yr) = sum(mapyr(yr,ust), gsp_all_(stf,stn,str,ctc,ctn,iid,icl,ids,ust));

set	in(stf,stn,str,ctc,ctn,iid,icl,ids,yr)		Used set tuples;
option 	in<gsp_all;

* Lose the superfluous descriptive columns:

parameter	gsp_(stf,yr,ctc,iid)	Trimmed GSP data;

gsp_(stf,yr,ctc,iid) = sum(in(stf,stn,str,ctc,ctn,iid,icl,ids,yr), gsp_all(stf,stn,str,ctc,ctn,iid,icl,ids,yr));

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
				/ gdp.200, taxsbd.300, cmp.400, sbd.500,tax.600
				  gos.700, qty.800, rgdp.900, perc.1000 /;

* Map to state abbreviations instead of FIPS codes and non-numeric
* sectoring detail:

set	r		State abbreviations /
			AL	"Alabama",
			AK	"Alaska",
			AZ	"Arizona",
			AR	"Arkansas",
			CA	"California",
			CO	"Colorado",
			CT	"Connecticut",
			DC	"District of Columbia",
			DE	"Delaware",
			FL	"Florida",
			GA	"Georgia",
			HI	"Hawaii",
			IA	"Iowa",
			ID	"Idaho",
			IL	"Illinois",
			IN	"Indiana",
			KS	"Kansas",
			KY	"Kentucky",
			LA	"Louisiana",
			MA	"Massachusetts",
			MD	"Maryland",
			ME	"Maine",
			MI	"Michigan",
			MN	"Minnesota",
			MO	"Missouri",
			MS	"Mississippi",
			MT	"Montana",
			NC	"North Carolina",
			ND	"North Dakota",
			NE	"Nebraska",
			NH	"New Hampshire",
			NJ	"New Jersey",
			NM	"New Mexico",
			NV	"Nevada",
			NY	"New York",
			OH	"Ohio",
			OK	"Oklahoma",
			OR	"Oregon",
			PA	"Pennsylvania",
			RI	"Rhode Island",
			SC	"South Carolina",
			SD	"South Dakota",
			TN	"Tennessee",
			TX	"Texas",
			UT	"Utah",
			VA	"Virginia",
			VT	"Vermont",
			WA	"Washington",
			WI	"Wisconsin",
			WV	"West Virginia",
			WY	"Wyoming" /,
	map(stf,r)	Mapping to state abbreviations /
			01000.AL "Alabama"
			02000.AK "Alaska"
			04000.AZ "Arizona"
			05000.AR "Arkansas"
			06000.CA "California"
			08000.CO "Colorado"
			09000.CT "Connecticut"
			10000.DE "Delaware"
			11000.DC "District of Columbia"
			12000.FL "Florida"
			13000.GA "Georgia"
			15000.HI "Hawaii"
			16000.ID "Idaho"
			17000.IL "Illinois"
			18000.IN "Indiana"
			19000.IA "Iowa"
			20000.KS "Kansas"
			21000.KY "Kentucky"
			22000.LA "Louisiana"
			23000.ME "Maine"
			24000.MD "Maryland"
			25000.MA "Massachusetts"
			26000.MI "Michigan"
			27000.MN "Minnesota"
			28000.MS "Mississippi"
			29000.MO "Missouri"
			30000.MT "Montana"
			31000.NE "Nebraska"
			32000.NV "Nevada"
			33000.NH "New Hampshire"
			34000.NJ "New Jersey"
			35000.NM "New Mexico"
			36000.NY "New York"
			37000.NC "North Carolina"
			38000.ND "North Dakota"
			39000.OH "Ohio"
			40000.OK "Oklahoma"
			41000.OR "Oregon"
			42000.PA "Pennsylvania"
			44000.RI "Rhode Island"
			45000.SC "South Carolina"
			46000.SD "South Dakota"
			47000.TN "Tennessee"
			48000.TX "Texas"
			49000.UT "Utah"
			50000.VT "Vermont"
			51000.VA "Virginia"
			53000.WA "Washington"
			54000.WV "West Virginia"
			55000.WI "Wisconsin"
			56000.WY "Wyoming" /;

parameter	gsp(r,yr,gdpcat,iid)	Mapped state level annual GDP;

loop(gdpmap(gdpcat,ctc),
	gsp(r,yr,gdpcat,iid) = sum(map(stf,r), gsp_(stf,yr,ctc,iid)););

execute_unload 'temp\gdx\gsp_raw.gdx' gsp,r,gdpcat,yr,iid=s;