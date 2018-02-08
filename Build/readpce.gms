$call 'gdxxrw i=..\Data\PCE\PCE_all.csv o=temp\gdx\PCE_all.gdx par=pce_all rng=a1..aa1441 cdim=1 rdim=8'
alias (GeoFIPS, ComponentId, ComponentName, Region, IndustryClassification, Description,*)
set	yr /1997*2015/;

set	GeoName /
"Alabama",
"Alaska",
"Arizona",
"Arkansas",
"California",
"Colorado",
"Connecticut",
"Delaware",
"District of Columbia",
"Far West",
"Florida",
"Georgia",
"Great Lakes",
"Hawaii",
"Idaho",
"Illinois",
"Indiana",
"Iowa",
"Kansas",
"Kentucky",
"Louisiana",
"Maine",
"Maryland",
"Massachusetts",
"Michigan",
"Mideast",
"Minnesota",
"Mississippi",
"Missouri",
"Montana",
"Nebraska",
"Nevada",
"New England",
"New Hampshire",
"New Jersey",
"New Mexico",
"New York",
"North Carolina",
"North Dakota",
"Ohio",
"Oklahoma",
"Oregon",
"Pennsylvania",
"Plains",
"Rhode Island",
"Rocky Mountain",
"South Carolina",
"South Dakota",
"Southeast",
"Southwest",
"Tennessee",
"Texas",
"United States",
"Utah",
"Vermont",
"Virginia",
"Washington",
"West Virginia",
"Wisconsin",
"Wyoming" /;

set	line /
1		"Personal consumption expenditures",
2		 "Goods",
3		  "Durable goods",
4		   "Motor vehicles and parts",
5		   "Furnishings and durable household equipment",
6		   "Recreational goods and vehicles",
7		   "Other durable goods",
8		  "Nondurable goods",
9		   "Food and beverages purchased for off-premises consumption",
10		   "Clothing and footwear",
11		   "Gasoline and other energy goods",
12		   "Other nondurable goods",
13		 "Services",
14		  "Household consumption expenditures (for services)",
15		  "Housing and utilities",
16		  "Health care",
17		  "Transportation services",
18		  "Recreation services",
19		  "Food services and accommodations",
20		  "Financial services and insurance",
21		  "Other services",
22		 "Final consumption expenditures of nonprofit institutions serving households (NPISHs)",
23		 "Gross output of nonprofit institutions",
24		 "Less: Receipts from sales of goods and services by nonprofit "/;


parameter	pce_all(GeoFIPS, GeoName, Region, ComponentId, ComponentName, Line, IndustryClassification, Description,yr);
$gdxin 'temp\gdx\pce_all.gdx'
$loaddc pce_all

set s States /
	AL	"Alabama"
	AK	"Alaska"
	AZ	"Arizona"
	AR	"Arkansas"
	CA	"California"
	CO	"Colorado"
	CT	"Connecticut"
	DE	"Delaware"
	DC	"District of Columbia"
	FL	"Florida"
	GA	"Georgia"
	HI	"Hawaii"
	ID	"Idaho"
	IL	"Illinois"
	IN	"Indiana"
	IA	"Iowa"
	KS	"Kansas"
	KY	"Kentucky"
	LA	"Louisiana"
	ME	"Maine"
	MD	"Maryland"
	MA	"Massachusetts"
	MI	"Michigan"
	MN	"Minnesota"
	MS	"Mississippi"
	MO	"Missouri"
	MT	"Montana"
	NE	"Nebraska"
	NV	"Nevada"
	NH	"New Hampshire"
	NJ	"New Jersey"
	NM	"New Mexico"
	NY	"New York"
	NC	"North Carolina"
	ND	"North Dakota"
	OH	"Ohio"
	OK	"Oklahoma"
	OR	"Oregon"
	PA	"Pennsylvania"
	RI	"Rhode Island"
	SC	"South Carolina"
	SD	"South Dakota"
	TN	"Tennessee"
	TX	"Texas"
	UT	"Utah"
	VT	"Vermont"
	VA	"Virginia"
	WA	"Washington"
	WV	"West Virginia"
	WI	"Wisconsin"
	WY	"Wyoming" /;

set	smap(s,geoname) /
   AL."Alabama"
   AK."Alaska"
   AZ."Arizona"
   AR."Arkansas"
   CA."California"
   CO."Colorado"
   CT."Connecticut"
   DE."Delaware"
   DC."District of Columbia"
   FL."Florida"
   GA."Georgia"
   HI."Hawaii"
   ID."Idaho"
   IL."Illinois"
   IN."Indiana"
   IA."Iowa"
   KS."Kansas"
   KY."Kentucky"
   LA."Louisiana"
   ME."Maine"
   MD."Maryland"
   MA."Massachusetts"
   MI."Michigan"
   MN."Minnesota"
   MS."Mississippi"
   MO."Missouri"
   MT."Montana"
   NE."Nebraska"
   NV."Nevada"
   NH."New Hampshire"
   NJ."New Jersey"
   NM."New Mexico"
   NY."New York"
   NC."North Carolina"
   ND."North Dakota"
   OH."Ohio"
   OK."Oklahoma"
   OR."Oregon"
   PA."Pennsylvania"
   RI."Rhode Island"
   SC."South Carolina"
   SD."South Dakota"
   TN."Tennessee"
   TX."Texas"
   UT."Utah"
   VT."Vermont"
   VA."Virginia"
   WA."Washington"
   WV."West Virginia"
   WI."Wisconsin"
   WY."Wyoming" /;

set	g	Goods (include aggregate categories) /
   pce		"Personal consumption expenditures",
   gds		 "Goods",
   dur		  "Durable goods",
   mvp		   "Motor vehicles and parts",
   hdr		   "Furnishings and durable household equipment",
   rec		   "Recreational goods and vehicles",
   odg		   "Other durable goods",
   ndr		  "Nondurable goods",
   foo		   "Food and beverages purchased for off-premises consumption",
   clo		   "Clothing and footwear",
   enr		   "Gasoline and other energy goods",
   ong		   "Other nondurable goods",
   ser		 "Services",
   hce		  "Household consumption expenditures (for services)",
   utl		  "Housing and utilities",
   hea		  "Health care",
   trn		  "Transportation services",
   rsr		  "Recreation services",
   htl		  "Food services and accommodations",
   fsr		  "Financial services and insurance",
   osr		  "Other services",
   npish	 "Final consumption expenditures of nonprofit institutions serving households (NPISHs)",
   npi		 "Gross output of nonprofit institutions",
   nps		 "Less: Receipts from sales of goods and services by nonprofit "/;

set gmap(line,g) /
1.pce	!		"Personal consumption expenditures",
2.gds	!		 "Goods",
3.dur	!		  "Durable goods",
4.mvp	!		   "Motor vehicles and parts",
5.hdr	!		   "Furnishings and durable household equipment",
6.rec	!		   "Recreational goods and vehicles",
7.odg	!		   "Other durable goods",
8.ndr	!		  "Nondurable goods",
9.foo	!		   "Food and beverages purchased for off-premises consumption",
10.clo	!		   "Clothing and footwear",
11.enr	!		   "Gasoline and other energy goods",
12.ong	!		   "Other nondurable goods",
13.ser	!		 "Services",
14.hce	!		  "Household consumption expenditures (for services)",
15.utl	!		  "Housing and utilities",
16.hea	!		  "Health care",
17.trn	!		  "Transportation services",
18.rsr	!		  "Recreation services",
19.htl	!		  "Food services and accommodations",
20.fsr	!		  "Financial services and insurance",
21.osr	!		  "Other services",
22.npish !	 "Final consumption expenditures of nonprofit institutions serving households (NPISHs)",
23.npi	!		 "Gross output of nonprofit institutions",
24.nps	!		 "Less: Receipts from sales of goods and services by nonprofit "
/;


parameter	pce(s,g,yr)	Personal consumer expenditure by commodity (including aggregate subtotals);

set	k(GeoFIPS, GeoName, Region, ComponentId, ComponentName, Line, IndustryClassification, Description);
option k<pce_all;

loop(k(GeoFIPS, GeoName, Region, ComponentId, ComponentName, line, IndustryClassification, Description),
	loop( (smap(s,GeoName),gmap(Line,g)),
	  pce(s,g,yr) = pce_all(k,yr););
);

option pce:3:0:1;
display pce;

execute_unload 'temp\gdx\pce_raw.gdx' pce, s, g, yr;