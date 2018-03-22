$stitle Routine for reading in USATrade Data

set	rr	Regions,
	gg	Commodities,
	yy	Year;

parameter	usatrd_exp	USATrade state exports,
		usatrd_imp	USATrade state imports;

$call 'gdxxrw i="..\Data\USATradeOnline\State Exports by NAICS Commodities.csv" o="..\Data\USATradeOnline\State Exports by NAICS Commodities.gdx" par=usatrd_exp rng="State Exports by NAICS Commodit"!A5 rdim=4 cdim=0';
$gdxin '..\Data\USATradeOnline\State Exports by NAICS Commodities.gdx'
$load usatrd_exp
$loaddc rr<=usatrd_exp.dim1 gg<=usatrd_exp.dim2 yy<=usatrd_exp.dim4

$call 'gdxxrw.exe i="..\Data\USATradeOnline\State Imports by NAICS Commodities.csv" o="..\Data\USATradeOnline\State Imports by NAICS Commodities.gdx" par=usatrd_imp rng="State Imports by NAICS Commodit"!A4 rdim=4 cdim=0';
$gdxin '..\Data\USATradeOnline\State Imports by NAICS Commodities.gdx'
$load usatrd_imp

set	r	States /
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
	g	NAICS goods /
		1111	 "Oilseeds & Grains",
		1112	 "Vegetables & Melons",
		1113	 "Fruits & Tree Nuts",
		1114	 "Mushrooms, Nursery & Related Products",
		1119	 "Other Agricultural Products",
		1121	 "Cattle",
		1122	 "Swine",
		1123	 "Poultry & Eggs",
		1124	 "Sheep, Goats & Fine Animal Hair",
		1125	 "Farmed Fish And Related Products",
		1129	 "Other Animals",
		1132	 "Forestry Products",
		1133	 "Timber & Logs",
		1141	 "Fish, Fresh/chilled/frozen & Other Marine Products",
		2111	 "Oil & Gas",
		2121	 "Coal & Petroleum Gases",
		2122	 "Metal Ores",
		2123	 "Nonmetallic Minerals",
		3111	 "Animal Foods",
		3112	 "Grain & Oilseed Milling Products",
		3113	 "Sugar & Confectionery Products",
		3114	 "Fruits & Veg Preserves & Specialty Foods",
		3115	 "Dairy Products",
		3116	 "Meat Products & Meat Packaging Products",
		3117	 "Seafood Prods, Prepared, Canned & Packaged",
		3118	 "Bakery & Tortilla Products",
		3119	 "Foods, Nesoi",
		3121	 "Beverages",
		3122	 "Tobacco Products",
		3131	 "Fibers, Yarns & Threads",
		3132	 "Fabrics",
		3133	 "Finished & Coated Textile Fabrics",
		3141	 "Textile Furnishings",
		3149	 "Other Textile Products",
		3151	 "Knit Apparel",
		3152	 "Apparel",
		3159	 "Apparel Accessories",
		3161	 "Leather & Hide Tanning",
		3162	 "Footwear",
		3169	 "Other Leather Products",
		3211	 "Sawmill & Wood Products",
		3212	 "Veneer, Plywood & Engineered Wood Products",
		3219	 "Other Wood Products",
		3221	 "Pulp, Paper & Paperboard Mill Products",
		3222	 "Converted Paper Products",
		3231	 "Printed Matter And Related Products, Nesoi",
		3241	 "Petroleum & Coal Products",
		3251	 "Basic Chemicals",
		3252	 "Resin, Syn Rubber, Artf & Syn Fibers/fil",
		3253	 "Pesticides, Fertilizers & Oth Agri Chemicals",
		3254	 "Pharmaceuticals & Medicines",
		3255	 "Paints, Coatings & Adhesives",
		3256	 "Soaps, Cleaning Compounds & Toilet Preparations",
		3259	 "Other Chemical Products & Preparations",
		3261	 "Plastics Products",
		3262	 "Rubber Products",
		3271	 "Clay & Refractory Products",
		3272	 "Glass & Glass Products",
		3273	 "Cement & Concrete Products",
		3274	 "Lime & Gypsum Products",
		3279	 "Other Nonmetallic Mineral Products",
		3311	 "Iron & Steel & Ferroalloy",
		3312	 "Steel Products From Purchased Steel",
		3313	 "Alumina & Aluminum  & Processing",
		3314	 "Nonferrous (exc Alum) & Processing",
		3315	 "Foundries",
		3321	 "Crowns/closures/seals & Other Packing Accessories",
		3322	 "Cutlery & Handtools",
		3323	 "Architectural & Structural Metals",
		3324	 "Boilers, Tanks & Shipping Containers",
		3325	 "Hardware",
		3326	 "Springs & Wire Products",
		3327	 "Bolts/nuts/scrws/rivts/washrs & Other Turned Prods",
		3329	 "Other Fabricated Metal Products",
		3331	 "Ag & Construction &  Machinery",
		3332	 "Industrial Machinery",
		3333	 "Commercial & Service Industry Machinery",
		3334	 "Hvac & Commercial Refrigeration Equipment",
		3335	 "Metalworking Machinery",
		3336	 "Engines, Turbines & Power Transmsn Equip",
		3339	 "Other General Purpose Machinery",
		3341	 "Computer Equipment",
		3342	 "Communications Equipment",
		3343	 "Audio & Video Equipment",
		3344	 "Semiconductors & Other Electronic Components",
		3345	 "Navigational/measuring/medical/control Instrument",
		3346	 "Magnetic & Optical Media",
		3351	 "Electric Lighting Equipment",
		3352	 "Household Appliances And Misc Machines, Nesoi",
		3353	 "Electrical Equipment",
		3359	 "Electrical Equipment & Components, Nesoi",
		3361	 "Motor Vehicles",
		3362	 "Motor Vehicle Bodies & Trailers",
		3363	 "Motor Vehicle Parts",
		3364	 "Aerospace Products & Parts",
		3365	 "Railroad Rolling Stock",
		3366	 "Ships & Boats",
		3369	 "Transportation Equipment, Nesoi",
		3371	 "Household & Institutional Furn & Kitchen Cabinets",
		3372	 "Office Furniture (including Fixtures)",
		3379	 "Furniture Related Products, Nesoi",
		3391	 "Medical Equipment & Supplies",
		3399	 "Miscellaneous Manufactured Commodities",
		5112	 "Software, Nesoi",
		9100	 "Waste And Scrap",
		9200	 "Used Or Second-hand Merchandise",
		9300	 "Used Or Second-hand Merchandise",
		9800	 "Goods Returned (exports For Canada Only)",
		9900	 "Other Special Classification Provisions" /,
	y	Year / 2002*2016 /;

set	mapr(r,rr)	Mapping between regions /
		AL."Alabama",
		AK."Alaska",
		AZ."Arizona",
		AR."Arkansas",
		CA."California",
		CO."Colorado",
		CT."Connecticut",
		DC."Dist of Columbia"
		DE."Delaware",
		FL."Florida",
		GA."Georgia",
		HI."Hawaii",
		ID."Idaho",
		IL."Illinois",
		IN."Indiana",
		IA."Iowa",
		KS."Kansas",
		KY."Kentucky",
		LA."Louisiana",
		ME."Maine",
		MD."Maryland",
		MA."Massachusetts",
		MI."Michigan",
		MN."Minnesota",
		MS."Mississippi",
		MO."Missouri",
		MT."Montana",
		NE."Nebraska",
		NV."Nevada",
		NH."New Hampshire",
		NJ."New Jersey",
		NM."New Mexico",
		NY."New York",
		NC."North Carolina",
		ND."North Dakota",
		OH."Ohio",
		OK."Oklahoma",
		OR."Oregon",
		PA."Pennsylvania",
		RI."Rhode Island",
		SC."South Carolina",
		SD."South Dakota",
		TN."Tennessee",
		TX."Texas",
		UT."Utah",
		VT."Vermont",
		VA."Virginia",
		WA."Washington",
		WV."West Virginia",
		WI."Wisconsin",
		WY."Wyoming" /,		
	mapg(g,gg)	Mapping between goods /
		1111."1111 Oilseeds & Grains",
		1112."1112 Vegetables & Melons",
		1113."1113 Fruits & Tree Nuts",
		1114."1114 Mushrooms, Nursery & Related Products",
		1119."1119 Other Agricultural Products",
		1121."1121 Cattle",
		1122."1122 Swine",
		1123."1123 Poultry & Eggs",
		1124."1124 Sheep, Goats & Fine Animal Hair",
		1125."1125 Farmed Fish And Related Products",
		1129."1129 Other Animals",
		1132."1132 Forestry Products",
		1133."1133 Timber & Logs",
		1141."1141 Fish, Fresh/chilled/frozen & Other Marine Products",
		2111."2111 Oil & Gas",
		2121."2121 Coal & Petroleum Gases",
		2122."2122 Metal Ores",
		2123."2123 Nonmetallic Minerals",
		3111."3111 Animal Foods",
		3112."3112 Grain & Oilseed Milling Products",
		3113."3113 Sugar & Confectionery Products",
		3114."3114 Fruits & Veg Preserves & Specialty Foods",
		3115."3115 Dairy Products",
		3116."3116 Meat Products & Meat Packaging Products",
		3117."3117 Seafood Prods, Prepared, Canned & Packaged",
		3118."3118 Bakery & Tortilla Products",
		3119."3119 Foods, Nesoi",
		3121."3121 Beverages",
		3122."3122 Tobacco Products",
		3131."3131 Fibers, Yarns & Threads",
		3132."3132 Fabrics",
		3133."3133 Finished & Coated Textile Fabrics",
		3141."3141 Textile Furnishings",
		3149."3149 Other Textile Products",
		3151."3151 Knit Apparel",
		3152."3152 Apparel",
		3159."3159 Apparel Accessories",
		3161."3161 Leather & Hide Tanning",
		3162."3162 Footwear",
		3169."3169 Other Leather Products",
		3211."3211 Sawmill & Wood Products",
		3212."3212 Veneer, Plywood & Engineered Wood Products",
		3219."3219 Other Wood Products",
		3221."3221 Pulp, Paper & Paperboard Mill Products",
		3222."3222 Converted Paper Products",
		3231."3231 Printed Matter And Related Products, Nesoi",
		3241."3241 Petroleum & Coal Products",
		3251."3251 Basic Chemicals",
		3252."3252 Resin, Syn Rubber, Artf & Syn Fibers/fil",
		3253."3253 Pesticides, Fertilizers & Oth Agri Chemicals",
		3254."3254 Pharmaceuticals & Medicines",
		3255."3255 Paints, Coatings & Adhesives",
		3256."3256 Soaps, Cleaning Compounds & Toilet Preparations",
		3259."3259 Other Chemical Products & Preparations",
		3261."3261 Plastics Products",
		3262."3262 Rubber Products",
		3271."3271 Clay & Refractory Products",
		3272."3272 Glass & Glass Products",
		3273."3273 Cement & Concrete Products",
		3274."3274 Lime & Gypsum Products",
		3279."3279 Other Nonmetallic Mineral Products",
		3311."3311 Iron & Steel & Ferroalloy",
		3312."3312 Steel Products From Purchased Steel",
		3313."3313 Alumina & Aluminum  & Processing",
		3314."3314 Nonferrous (exc Alum) & Processing",
		3315."3315 Foundries",
		3321."3321 Crowns/closures/seals & Other Packing Accessories",
		3322."3322 Cutlery & Handtools",
		3323."3323 Architectural & Structural Metals",
		3324."3324 Boilers, Tanks & Shipping Containers",
		3325."3325 Hardware",
		3326."3326 Springs & Wire Products",
		3327."3327 Bolts/nuts/scrws/rivts/washrs & Other Turned Prods",
		3329."3329 Other Fabricated Metal Products",
		3331."3331 Ag & Construction &  Machinery",
		3332."3332 Industrial Machinery",
		3333."3333 Commercial & Service Industry Machinery",
		3334."3334 Hvac & Commercial Refrigeration Equipment",
		3335."3335 Metalworking Machinery",
		3336."3336 Engines, Turbines & Power Transmsn Equip",
		3339."3339 Other General Purpose Machinery",
		3341."3341 Computer Equipment",
		3342."3342 Communications Equipment",
		3343."3343 Audio & Video Equipment",
		3344."3344 Semiconductors & Other Electronic Components",
		3345."3345 Navigational/measuring/medical/control Instrument",
		3346."3346 Magnetic & Optical Media",
		3351."3351 Electric Lighting Equipment",
		3352."3352 Household Appliances And Misc Machines, Nesoi",
		3353."3353 Electrical Equipment",
		3359."3359 Electrical Equipment & Components, Nesoi",
		3361."3361 Motor Vehicles",
		3362."3362 Motor Vehicle Bodies & Trailers",
		3363."3363 Motor Vehicle Parts",
		3364."3364 Aerospace Products & Parts",
		3365."3365 Railroad Rolling Stock",
		3366."3366 Ships & Boats",
		3369."3369 Transportation Equipment, Nesoi",
		3371."3371 Household & Institutional Furn & Kitchen Cabinets",
		3372."3372 Office Furniture (including Fixtures)",
		3379."3379 Furniture Related Products, Nesoi",
		3391."3391 Medical Equipment & Supplies",
		3399."3399 Miscellaneous Manufactured Commodities",
		5112."5112 Software, Nesoi",
		9100."9100 Waste And Scrap",
		9200."9200 Used Or Second-hand Merchandise",
		9300."9300 Used Or Second-hand Merchandise",
		9800."9800 Goods Returned (exports For Canada Only)",
		9900."9900 Other Special Classification Provisions" /,	
	mapy(y,yy)	Mapping between years /
		2002."2002",
		2003."2003",
		2004."2004",
		2005."2005",
		2006."2006",
		2007."2007",
		2008."2008",
		2009."2009",
		2010."2010",
		2011."2011",
		2012."2012",
		2013."2013",
		2014."2014",
		2015."2015",
		2016."2016" /;

parameter	usatrd(r,g,y,*)	USA Trade data;

* Denote trades in millions of dollars.

usatrd(r,g,y,"exports") = sum((mapr(r,rr), mapg(g,gg), mapy(y,yy)), usatrd_exp(rr,gg,"World Total",yy))*1e-6;
usatrd(r,g,y,"imports") = sum((mapr(r,rr), mapg(g,gg), mapy(y,yy)), usatrd_imp(rr,gg,"World Total",yy))*1e-6;

execute_unload "..\Data\USATradeOnline\statetrade.gdx", usatrd, r,g,y;
execute 'gdxxrw i=..\Data\USATradeOnline\statetrade.gdx o=..\Data\USATradeOnline\statetrade.xlsx par=usatrd rng=data! rdim=3 cdim=1 set=g rng=naics! rdim=1';