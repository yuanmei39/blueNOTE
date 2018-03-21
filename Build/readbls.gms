$stitle Program for compiling BLS data on unemployment rates

$ontext
Series.txt provides an overview on when all available unemployment data is
available.

SERIES_ID (part of localarea_un_timeseries.txt) is divided as follows:
LAUST_statefips_00000000000_measurecode

Footnote codes (footnote.txt):
A	Area boundaries do not reflect official OMB definitions.	
B	Reflects revised population controls, model reestimation, and new seasonal adjustment.	
C	Corrected.	
D	Reflects revised population controls and model reestimation.	
N	Not available.	
P	Preliminary.	
R	Data were subject to revision on April 21, 2017.	
S	Reflects new population controls and revised seasonal adjustment.	
T	Reflects new population controls.

Measure codes (measure.txt):
03	unemployment rate	
04	unemployment	
05	employment	
06	labor force	

Period	codes (period.txt):
M01	JAN	January
M02	FEB	February
M03	MAR	March
M04	APR	April
M05	MAY	May
M06	JUN	June
M07	JUL	July
M08	AUG	August
M09	SEP	September
M10	OCT	October
M11	NOV	November
M12	DEC	December
M13	AN AV	Annual Average

Region codes (states.txt):
01	Alabama	
02	Alaska	
04	Arizona	
05	Arkansas	
06	California	
08	Colorado	
09	Connecticut	
10	Delaware	
11	District of Columbia	
12	Florida	
13	Georgia	
15	Hawaii	
16	Idaho	
17	Illinois	
18	Indiana	
19	Iowa	
20	Kansas	
21	Kentucky	
22	Louisiana	
23	Maine	
24	Maryland	
25	Massachusetts	
26	Michigan	
27	Minnesota	
28	Mississippi	
29	Missouri	
30	Montana	
31	Nebraska	
32	Nevada	
33	New Hampshire	
34	New Jersey	
35	New Mexico	
36	New York	
37	North Carolina	
38	North Dakota	
39	Ohio	
40	Oklahoma	
41	Oregon	
42	Pennsylvania	
44	Rhode Island	
45	South Carolina	
46	South Dakota	
47	Tennessee	
48	Texas	
49	Utah	
50	Vermont	
51	Virginia	
53	Washington	
54	West Virginia	
55	Wisconsin	
56	Wyoming	
72	Puerto Rico	
80	Census Regions and Divisions

$offtext

set	f	Footnote codes,
	y	Year,
	p	Period,
	id	Series id;

parameter	blsdata_all	Raw Bureau of Labor Statistics data;

$call 'csv2gdx ..\Data\BLS_Unemp\localarea_un_timeseries.txt Output=..\Data\BLS_Unemp\localarea_un_timeseries.gdx id=blsdata_all useheader=y index=(1,2,3,5) values=4 fieldsep=tab'
$gdxin ..\Data\BLS_Unemp\localarea_un_timeseries.gdx
$load blsdata_all
$loaddc f<=blsdata_all.dim4 y<=blsdata_all.dim2 p<=blsdata_all.dim3 id<=blsdata_all.dim1

* Only keep annual state level unemployment rates (period=M13, measure=03):

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
	mapid(r,id)	Mapping between series ID and region /
		AL.LAUST010000000000003,
		AK.LAUST020000000000003,
		AZ.LAUST040000000000003,
		AR.LAUST050000000000003,
		CA.LAUST060000000000003,
		CO.LAUST080000000000003,
		CT.LAUST090000000000003,
		DE.LAUST100000000000003,
		DC.LAUST110000000000003,
		FL.LAUST120000000000003,
		GA.LAUST130000000000003,
		HI.LAUST150000000000003,
		ID.LAUST160000000000003,
		IL.LAUST170000000000003,
		IN.LAUST180000000000003,
		IA.LAUST190000000000003,
		KS.LAUST200000000000003,
		KY.LAUST210000000000003,
		LA.LAUST220000000000003,
		ME.LAUST230000000000003,
		MD.LAUST240000000000003,
		MA.LAUST250000000000003,
		MI.LAUST260000000000003,
		MN.LAUST270000000000003,
		MS.LAUST280000000000003,
		MO.LAUST290000000000003,
		MT.LAUST300000000000003,
		NE.LAUST310000000000003,
		NV.LAUST320000000000003,
		NH.LAUST330000000000003,
		NJ.LAUST340000000000003,
		NM.LAUST350000000000003,
		NY.LAUST360000000000003,
		NC.LAUST370000000000003,
		ND.LAUST380000000000003,
		OH.LAUST390000000000003,
		OK.LAUST400000000000003,
		OR.LAUST410000000000003,
		PA.LAUST420000000000003,
		RI.LAUST440000000000003,
		SC.LAUST450000000000003,
		SD.LAUST460000000000003,
		TN.LAUST470000000000003,
		TX.LAUST480000000000003,
		UT.LAUST490000000000003,
		VT.LAUST500000000000003,
		VA.LAUST510000000000003,
		WA.LAUST530000000000003,
		WV.LAUST540000000000003,
		WI.LAUST550000000000003,
		WY.LAUST560000000000003 /;

parameter	blsrates_(r,y,f)	State level unemployment statistics,
		blsrates(r,y)		State level unemployment statistics;

blsrates_(r,y,f) = sum(mapid(r,id), blsdata_all(id,y,"M13",f));

* Are there any overlap between footnote items?

parameter	chkfoot;

chkfoot(r,y) = sum(f$blsrates_(r,y,f), 1);
abort$(smax((r,y), chkfoot(r,y)) > 1) 'Multiple entries detected in BLS data.';

blsrates(r,y) = sum(f, blsrates_(r,y,f));

execute_unload '..\Data\BLS_Unemp\bls_urates.gdx' blsrates;
execute 'gdxxrw i=..\Data\BLS_Unemp\bls_urates.gdx o=..\Data\BLS_Unemp\bls_urates.xlsx par=blsrates rdim=2';