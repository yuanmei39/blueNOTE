$stitle Program for reconciling PUM CFS data for 2012

$ontext

Data is scaled to be in millions of dollars.

PUM CFS data is provided as a text file with headers (4.5 million observations):

SHIPMT_ID,ORIG_STATE,ORIG_MA,ORIG_CFS_AREA,DEST_STATE,DEST_MA,DEST_CFS_AREA,
NAICS,QUARTER,SCTG,MODE,SHIPMT_VALUE,SHIPMT_WGHT,SHIPMT_DIST_GC,SHIPMT_DIST_ROUTED,
TEMP_CNTL_YN,EXPORT_YN,EXPORT_CNTRY,HAZMAT,WGT_FACTOR

I extract a portion of these data columns:

SHIPMT_ID,ORIG_STATE,ORIG_MA,DEST_STATE,DEST_MA,NAICS,SCTG,
SHIPMT_VALUE,EXPORT_YN,WGT_FACTOR

$offtext

set	id	Shipment ID,
	rr	Region,
	maa	Metropolitan area,
	n	NAICS,
	s	SCTG code,
	e	Binary for export (Y);

$call 'csv2gdx ..\Data\CFS\cfs_2012_pumf_csv.txt Output=..\Data\CFS\cfs_2012_pumf_csv.gdx id=cfsdata_all useheader=y index=(1,2,3,5,6,8,10,17) values=(12,20) checkdate=y'
$gdxin '..\Data\CFS\cfs_2012_pumf_csv.gdx'
$loaddc id=Dim1 rr=Dim2 maa=Dim3 n=Dim6 s=Dim7 e=Dim8
alias(rr,rg),(maa,met);

parameter	cfsdata_all(id,rr,maa,rg,met,n,s,e,*)	Raw Commodity Flow Survey Data;
$loaddc cfsdata_all

set 	in(id,rr,maa,rg,met,n,s,e);
option 	in<cfsdata_all;

* Map state fips codes to state abbreviations:

set	r	Regions /
		AL	"Alabama",
		AK	"Alaska",
		AZ	"Arizona",
		AR	"Arkansas",
		CA	"California",
		CO	"Colorado",
		CT	"Connecticut",
		DC	"Dist of Columbia"
		DE	"Delaware",
		FL	"Florida",
		GA	"Georgia",
		HI	"Hawaii",
		ID	"Idaho",
		IL	"Illinois",
		IN	"Indiana",
		IA	"Iowa",
		KS	"Kansas",
		KY	"Kentucky",
		LA	"Louisiana",
		ME	"Maine",
		MD	"Maryland",
		MA	"Massachusetts",
		MI	"Michigan",
		MN	"Minnesota",
		MS	"Mississippi",
		MO	"Missouri",
		MT	"Montana",
		NE	"Nebraska",
		NV	"Nevada",
		NH	"New Hampshire",
		NJ	"New Jersey",
		NM	"New Mexico",
		NY	"New York",
		NC	"North Carolina",
		ND	"North Dakota",
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
		VT	"Vermont",
		VA	"Virginia",
		WA	"Washington",
		WV	"West Virginia",
		WI	"Wisconsin",
		WY	"Wyoming" /,
	mapr(r,rr)	Mapping between region indices /
		AL.01,AK.02,AZ.04,AR.05,CA.06,CO.08,CT.09,DE.10,DC.11,
		FL.12,GA.13,HI.15,ID.16,IL.17,IN.18,IA.19,KS.20,KY.21,
		LA.22,ME.23,MD.24,MA.25,MI.26,MN.27,MS.28,MO.29,MT.30,
		NE.31,NV.32,NH.33,NJ.34,NM.35,NY.36,NC.37,ND.38,OH.39,
		OK.40,OR.41,PA.42,RI.44,SC.45,SD.46,TN.47,TX.48,UT.49,
		VT.50,VA.51,WA.53,WV.54,WI.55,WY.56 /;

alias (r,st),(rr,rg),(maa,met),(mapr,maprr),(k,*);

* Do some data cleaning:

* 1) Drop all data associated with foreign exports:

cfsdata_all(id,rr,maa,rg,met,n,s,"Y",k) = 0;

* 2) Drop missing or suppressed data:

cfsdata_all(id,"00",maa,rg,met,n,s,e,k) = 0;
cfsdata_all(id,rr,maa,"00",met,n,s,e,k) = 0;

set	nd(s)	Undisclosed SCTG code /
		"00","25-30","01-05","15-19","10-14","06-09",
		"39-99","20-24","31-34","35-38","99" /;

cfsdata_all(id,rr,maa,rg,met,n,nd,e,k) = 0;

* Final result: origin, destination, naics, sctg, total value.

parameter	cfsdata_st(r,st,n,s)	State level shipments (value),
		cfsdata_ma(maa,met,n,s)	Metropolitan area level shipments (value);

cfsdata_st(r,st,n,s) = sum((mapr(r,rr),maprr(st,rg)), sum(in(id,rr,maa,rg,met,n,s,e), 
		cfsdata_all(id,rr,maa,rg,met,n,s,e,'WGT_FACTOR') * 
		cfsdata_all(id,rr,maa,rg,met,n,s,e,'SHIPMT_VALUE'))) * 1e-6;
cfsdata_ma(maa,met,n,s) = sum(in(id,rr,maa,rg,met,n,s,e), 
		cfsdata_all(id,rr,maa,rg,met,n,s,e,'WGT_FACTOR') * 
		cfsdata_all(id,rr,maa,rg,met,n,s,e,'SHIPMT_VALUE')) * 1e-6;

execute_unload '..\Data\CFS\cfsdata_2012.gdx', cfsdata_st, cfsdata_ma, r, maa, n, s;
execute 'gdxxrw.exe i=..\Data\CFS\cfsdata_2012.gdx o=..\Data\CFS\cfsdata_2012.xlsx par=cfsdata_st rng=statedata! cdim=0 par=cfsdata_ma rng=metrodata! cdim=0 set=r rng=states! rdim=1 set=maa rng=metros! rdim=1 set=n rng=naics! rdim=1 set=s rng=sctg! rdim=1';