$title	Read State Government Finances Summary Tables (1997-2015)

* ------------------------------------------------------------------------------
* Declare sets:
* ------------------------------------------------------------------------------

set	states /
	AL	"ALABAMA",
	AK	"ALASKA",
	AZ	"ARIZONA",
	AR	"ARKANSAS",
	CA	"CALIFORNIA",
	CO	"COLORADO",
	CT	"CONNECTICUT",
	DE	"DELAWARE",
	FL	"FLORIDA",
	GA	"GEORGIA",
	HI	"HAWAII",
	ID	"IDAHO",
	IL	"ILLINOIS",
	IN	"INDIANA",
	IA	"IOWA",
	KS	"KANSAS",
	KY	"KENTUCKY",
	LA	"LOUISIANA",
	ME	"MAINE",
	MD	"MARYLAND",
	MA	"MASSACHUSETTS",
	MI	"MICHIGAN",
	MN	"MINNESOTA",
	MS	"MISSISSIPPI",
	MO	"MISSOURI",
	MT	"MONTANA",
	NE	"NEBRASKA",
	NV	"NEVADA",
	NH	"NEW HAMPSHIRE",
	NJ	"NEW JERSEY",
	NM	"NEW MEXICO",
	NY	"NEW YORK",
	NC	"NORTH CAROLINA",
	ND	"NORTH DAKOTA",
	OH	"OHIO",
	OK	"OKLAHOMA",
	OR	"OREGON",
	PA	"PENNSYLVANIA",
	RI	"RHODE ISLAND",
	SC	"SOUTH CAROLINA",
	SD	"SOUTH DAKOTA",
	TN	"TENNESSEE",
	TX	"TEXAS",
	UT	"UTAH",
	VT	"VERMONT",
	VA	"VIRGINIA",
	WA	"WASHINGTON",
	WV	"WEST VIRGINIA",
	WI	"WISCONSIN",
	WY	"WYOMING" /;

set	sgfdata /
	SGF001	"Total Revenue",
	SGF002	"Total Revenue - General Revenue",
	SGF003	"Total Revenue - General Revenue - Intergovernmental Revenue",
	SGF004	"Total Revenue - General Revenue - Intergovernmental Revenue - From Federal",
	SGF005	"Total Revenue - General Revenue - Intergovernmental Revenue - From Local",
	SGF006	"Total Revenue - General Revenue - Total Taxes",
	SGF007	"Total Revenue - General Revenue - Total Taxes - General Sales and Gross Receipts Taxes",
	SGF008	"Total Revenue - General Revenue - Total Taxes - Selective Sales and Gross Receipts Taxes",
	SGF009	"Total Revenue - General Revenue - Total Taxes - License Taxes",
	SGF010	"Total Revenue - General Revenue - Total Taxes - Individual Income Taxes",
	SGF011	"Total Revenue - General Revenue - Total Taxes - Corporation Net Income Taxes",
	SGF012	"Total Revenue - General Revenue - Total Taxes - All Other Taxes",
	SGF013	"Total Revenue - General Revenue - Current Charges",
	SGF014	"Total Revenue - General Revenue - Miscellaneous General Revenue",
	SGF015	"Total Revenue - Utility Revenue",
	SGF016	"Total Revenue - Liquor Stores Revenue",
	SGF017	"Total Revenue - Insurance Trust Revenue (1)",
	SGF018	"Total Revenue - Insurance Trust Revenue (1) - Unemployment Compensation Systems",
	SGF019	"Total Revenue - Insurance Trust Revenue (1) - State-Administered Pension Systems",
	SGF020	"Total Revenue - Insurance Trust Revenue (1) - Workers' Compensation Systems",
	SGF021	"Total Revenue - Insurance Trust Revenue (1) - Other Insurance Trust Systems",
	SGF022	"Total Expenditure",
	SGF023	"Total Expenditure - Intergovernmental Expenditure",
	SGF024	"Total Expenditure - Direct Expenditure",
	SGF025	"Total Expenditure - Direct Expenditure - Current Operations",
	SGF026	"Total Expenditure - Direct Expenditure - Capital Outlay",
	SGF027	"Total Expenditure - Direct Expenditure - Insurance Benefits and Repayments",
	SGF028	"Total Expenditure - Direct Expenditure - Assistance and Subsidies",
	SGF029	"Total Expenditure - Direct Expenditure - Interest on Debt",
	SGF030	"Total Expenditure - Exhibit: Salaries and Wages",
	SGF032	"Total Expenditure - General Expenditure",
	SGF033	"Total Expenditure - General Expenditure - Intergovernmental General Expenditure",
	SGF034	"Total Expenditure - General Expenditure - Direct General Expenditure",
	SGF036	"General Expenditure, by Function: - Education",
	SGF037	"General Expenditure, by Function: - Public Welfare",
	SGF038	"General Expenditure, by Function: - Hospitals",
	SGF039	"General Expenditure, by Function: - Health",
	SGF040	"General Expenditure, by Function: - Highways",
	SGF041	"General Expenditure, by Function: - Police Protection",
	SGF042	"General Expenditure, by Function: - Correction",
	SGF043	"General Expenditure, by Function: - Natural Resources",
	SGF044	"General Expenditure, by Function: - Parks and Recreation",
	SGF045	"General Expenditure, by Function: - Governmental Administration",
	SGF046	"General Expenditure, by Function: - Interest on General Debt",
	SGF047	"General Expenditure, by Function: - Other and Unallocable",
	SGF048	"Utility Expenditure",
	SGF049	"Liquor Stores Expenditure",
	SGF050	"Insurance Trust Expenditure",
	SGF051	"Insurance Trust Expenditure - Unemployment Compensation Systems",
	SGF052	"Insurance Trust Expenditure - State-Administered Pension Systems",
	SGF053	"Insurance Trust Expenditure - Workers' Compensation Systems",
	SGF054	"Insurance Trust Expenditure - Other Insurance Trust Systems",
	SGF055	"Debt Outstanding, Long Term and Short Term",
	SGF056	"Cash and Security Holdings" /;

set	sgfid	SGF mneumonic identifiers /
	TOTREV	"Total Revenue (SGF001)",
	GENREV	"General revenue (SGF002)"
	INTREV	"Intergovernmental revenue (SGF003)"
	INTFED	"Intergovernmental Revenue - From Federal (SGF004)",
	INTLOC	"Intergovernmental Revenue - From Local (SGF005)",
	TAXREV	"Taxes (SGF006)"
	GSALES	"General sales (SGF007)"
	SSALES	"Selective sales (SGF008)"
	LICTAX	"License taxes (SGF009)"
	INDTAX	"Individual income tax (SGF010)"
	CORTAX	"Corporate income tax (SGF011)"
	OTHTAX	"Other taxes (SGF012)"
	CURCHG	"Current charges (SGF013)"
	MSCREV	"Miscellaneous general revenue (SGF014)"
	UTLREV	"Utility revenue (SGF015)"
	LIQREV	"Liquor store revenue (SGF016)"
	INSREV	"Insurance trust revenue (SGF017)"
	UNEMPL	"Insurance revenue - Unemployment Compensation Systems (SGF018)",
	PENSON	"Insurance revenue - State-Administered Pension Systems (SGF019)",
	WRKCMP	"Insurance revenue - Workers' Compensation Systems (SGF020)",
	OTHINS	"Insurance revenue - Other Insurance Trust Systems (SGF021)",
	TOTEXP	"Total expenditure (SGF022)"
	INTEXP	"Intergovernmental expenditure (SGF023)"
	DIREXP	"Direct expenditure (SGF024)"
	CUROPR	"Current operation (SGF025)"
	CAPOUT	"Capital outlay (SGF026)"
	INSBEN	"Insurance benefits and repayments (SGF027)"
	SUBSID	"Assistance and subsidies (SGF028)"
	INTRST	"Interest on debt (SGF029)"
	SALARY	"Exhibit: Salaries and wages (SGF030)"
	GENEXP	"General expenditure (SGF032)"
	DIRGEX	"Direct General Expenditure (SGF034)",	
	EDUCAT	"Education (SGF036)"
	PUBWEL	"Public welfare (SGF037)"
	HOSPTL	"Hospitals (SGF038)"
	HEALTH	"Health (SGF039)"
	HGHWAY	"Highways (SGF040)"
	POLICE	"Police protection (SGF041)"
	CORREC	"Correction (SGF042)"
	NATRES	"Natural resources (SGF043)"
	PARKRC	"Parks and recreation (SGF044)"
	GOVADM	"Government administration (SGF045)"
	INTGEN	"Interest on general debt (SGF046)"
	OTHUNA	"Other and unallocable (SGF047)"
	UTLEXP	"Utility expenditure (SGF048)"
	LIQEXP	"Liquor store expenditure (SGF049)"
	INSEXP	"Insurance trust expenditure (SGF050)"
	DEBTFY	"Debt at end of fiscal year (SGF055)"
	CASHSH	"Cash and security holdings (SGF056)" /;

set	idmap(sgfid,sgfdata) /
	TOTREV.SGF001	"Total Revenue"
	GENREV.SGF002	"General revenue",
	INTREV.SGF003	"Intergovernmental revenue"
	INTFED.SGF004	"Total Revenue - General Revenue - Intergovernmental Revenue - From Federal",
	INTLOC.SGF005	"Total Revenue - General Revenue - Intergovernmental Revenue - From Local",
	TAXREV.SGF006	"Taxes"
	GSALES.SGF007	"General sales"
	SSALES.SGF008	"Selective sales"
	LICTAX.SGF009	"License taxes"
	INDTAX.SGF010	"Individual income tax"
	CORTAX.SGF011	"Corporate income tax"
	OTHTAX.SGF012	"Other taxes"
	CURCHG.SGF013	"Current charges"
	MSCREV.SGF014	"Miscellaneous general revenue"
	UTLREV.SGF015	"Utility revenue"
	LIQREV.SGF016	"Liquor store revenue"
	INSREV.SGF017	"Insurance trust revenue"
	UNEMPL.SGF018	"Total Revenue - Insurance Trust Revenue (1) - Unemployment Compensation Systems",
	PENSON.SGF019	"Total Revenue - Insurance Trust Revenue (1) - State-Administered Pension Systems",
	WRKCMP.SGF020	"Total Revenue - Insurance Trust Revenue (1) - Workers' Compensation Systems",
	OTHINS.SGF021	"Total Revenue - Insurance Trust Revenue (1) - Other Insurance Trust Systems",
	TOTEXP.SGF022	"Total expenditure"
	INTEXP.SGF023	"Intergovernmental expenditure"
	DIREXP.SGF024	"Direct expenditure"
	CUROPR.SGF025	"Current operation"
	CAPOUT.SGF026	"Capital outlay"
	INSBEN.SGF027	"Insurance benefits and repayments"
	SUBSID.SGF028	"Assistance and subsidies"
	INTRST.SGF029	"Interest on debt"
	SALARY.SGF030	"Exhibit: Salaries and wages"
	GENEXP.SGF032	"General expenditure"
	DIRGEX.SGF034	"Direct General Expenditure",
	EDUCAT.SGF036	"Education"
	PUBWEL.SGF037	"Public welfare"
	HOSPTL.SGF038	"Hospitals"
	HEALTH.SGF039	"Health"
	HGHWAY.SGF040	"Highways"
	POLICE.SGF041	"Police protection"
	CORREC.SGF042	"Correction"
	NATRES.SGF043	"Natural resources"
	PARKRC.SGF044	"Parks and recreation"
	GOVADM.SGF045	"Government administration"
	INTGEN.SGF046	"Interest on general debt"
	OTHUNA.SGF047	"Other and unallocable"
	UTLEXP.SGF048	"Utility expenditure"
	LIQEXP.SGF049	"Liquor store expenditure"
	INSEXP.SGF050	"Insurance trust expenditure"
	DEBTFY.SGF055	"Debt at end of fiscal year"
	CASHSH.SGF056	"Cash and security holdings" /;


* ------------------------------------------------------------------------------
* The 1997 SGF tables requires re-arrangement:
* ------------------------------------------------------------------------------

* Read raw data:

set	k /1*53/;

alias (id,rg,*);
set	regions(id,rg) /
	us."United States"
	al."Alabama"
	ak."Alaska"
	az."Arizona"
	ar."Arkansas"
	ca."California"
	co."Colorado"
	ct."Connecticut"
	de."Delaware"
	fl."Florida"
	ga."Georgia"
	hi."Hawaii"
	id."Idaho"
	il."Illinois"
	in."Indiana"
	ia."Iowa"
	ks."Kansas"
	ky."Kentucky"
	la."Louisiana"
	me."Maine"
	md."Maryland"
	ma."Massachusetts"
	mi."Michigan"
	mn."Minnesota"
	ms."Mississippi"
	mo."Missouri"
	mt."Montana"
	ne."Nebraska"
	nv."Nevada"
	nh."New Hampshire"
	nj."New Jersey"
	nm."New Mexico"
	ny."New York"
	nc."North Carolina"
	nd."North Dakota"
	oh."Ohio"
	ok."Oklahoma"
	or."Oregon"
	pa."Pennsylvania"
	ri."Rhode Island"
	sc."South Carolina"
	sd."South Dakota"
	tn."Tennessee"
	tx."Texas"
	ut."Utah"
	vt."Vermont"
	va."Virginia"
	wa."Washington"
	wv."West Virginia"
	wi."Wisconsin"
	wy."Wyoming" /

$call 'xlsdump ..\Data\SGF\97states.xls "%gams.scrdir%97states.gdx"'
$call 'gdxdump "%gams.scrdir%97states.gdx" output="%gams.scrdir%97states.gms" noheader nodata'
$include "%gams.scrdir%97states"

option vu:0:0:1;
display vu;

set	rn(r) /r7/;

alias (u,*);

parameter	data(k,u,id)	State government finances;

set	echop, extract;

loop(regions(id,rg),
  echop(id,rn) = yes;
  loop(rn(r),
    loop(k,
      loop(vu("s1",r+(k.val),"c1",u),
	data(k,u,id) = vf("s1",r+(k.val),"c2");
  )));
  rn(r+54)$rn(r) = yes;
  rn(r)$rn(r+54) = no;
);

option data:3:2:1;
display data;

* Relabel data to match SGF labels in other tables. First define
* relational set to the data parameter:

set	m(k,u)	Matched row and descriptive labels;

m(k,u) = yes$(sum(id, data(k,u,id)));

set	sl	SGF Labels /
		SGF001 	"Total Revenue: SGF001"
		SGF002 	"General revenue: SGF002"
		SGF003 	"Intergovernmental revenue: SGF003"
		SGF006 	"Taxes: SGF006"
		SGF007 	"General sales"
		SGF008 	"Selective sales"
		SGF009 	"License taxes"
		SGF010 	"Individual income"
		SGF011 	"Corporation net income"
		SGF012 	"Other taxes"
		SGF013 	"Current charges"
		SGF014 	"Miscellaneous general revenue: SGF014"
		SGF015 	"Utility revenue: SGF015"
		SGF016 	"Liquor stores revenue: SGF016"
		SGF017 	"Insurance trust revenue: SGF017"
		SGF022 	"Total Expenditure: SGF022"
		SGF023 	"Intergovernmental expenditure: SGF023"
		SGF024 	"Direct expenditure"
		SGF025 	"Current operation"
		SGF026 	"Capital outlay"
		SGF027 	"Insurance benefits and repayments: SGF027"
		SGF028 	"Assistance and subsidies"
		SGF029 	"Interest on debt: SGF029"
		SGF030 	"Exhibit: Salaries and wages: SGF030"
		SGF032 	"General expenditure: SGF032"
		SGF034 	"Direct expenditure: SGF034"
		SGF036 	"Education"
		SGF037 	"Public welfare: SGF037"
		SGF038 	"Hospitals: SGF038"
		SGF039 	"Health"
		SGF040 	"Highways"
		SGF041 	"Police protection: SGF041"
		SGF042 	"Correction"
		SGF043 	"Natural resources: SGF043"
		SGF044 	"Parks and recreation: SGF044"
		SGF045 	"Governmental administration"
		SGF046 	"Interest on general debt: SGF046"
		SGF047 	"Other and unallocable: SGF047"
		SGF048 	"Utility expenditure: SGF048"
		SGF049 	"Liquor stores expenditure: SGF049"
		SGF050 	"Insurance trust expenditure: SGF050"
		SGF055 	"Debt at end of fiscal year: SGF055"
		SGF056 	"Cash and Security Holdings: SGF056"
		pop 	"Population (thousands): pop" /,

	map(sl,k)	Mapping between indices /
		pop.2		"Population (thousands)",
		SGF001.3	"Total Revenue",
		SGF002.4	"General revenue",
		SGF003.5	"Intergovernmental revenue",
		SGF006.6	"Taxes",
		SGF007.7	"General sales",
		SGF008.8	"Selective sales",
		SGF009.9	"License taxes",
		SGF010.10	"Individual income",
		SGF011.11	"Corporation net income",
		SGF012.12	"Other taxes",
		SGF013.13	"Current charges",
		SGF014.14	"Miscellaneous general revenue",
		SGF015.15	"Utility revenue",
		SGF016.16	"Liquor stores revenue",
		SGF017.17	"Insurance trust revenue",
		SGF022.19	"Total Expenditure",
		SGF023.20	"Intergovernmental expenditure",
		SGF024.21	"Direct expenditure",
		SGF025.22	"Current operation",
		SGF026.23	"Capital outlay",
		SGF027.24	"Insurance benefits and repayments",
		SGF028.25	"Assistance and subsidies",
		SGF029.26	"Interest on debt",
		SGF030.27	"Exhibit: Salaries and wages",
		SGF032.30	"General expenditure",
		SGF034.32	"Direct expenditure",
		SGF036.34	"Education",
		SGF037.35	"Public welfare",
		SGF038.36	"Hospitals",
		SGF039.37	"Health",
		SGF040.38	"Highways",
		SGF041.39	"Police protection",
		SGF042.40	"Correction",
		SGF043.41	"Natural resources",
		SGF044.42	"Parks and recreation",
		SGF045.43	"Governmental administration",
		SGF046.44	"Interest on general debt",
		SGF047.45	"Other and unallocable",
		SGF048.46	"Utility expenditure",
		SGF049.47	"Liquor stores expenditure",
		SGF050.48	"Insurance trust expenditure",
		SGF055.50	"Debt at end of fiscal year",
		SGF056.52	"Cash and Security Holdings" /;

parameter	data_(sl,id)	Mapped data;

loop((map(sl,k),m(k,u)),
data_(sl,id) = data(k,u,id);
);

* Drop population statistics and aggregate US accounts and output
* reconciled data file.

data_(sl,id)$(sameas(sl,'pop') or sameas(id,'us')) = 0;

execute_unload '..\Data\SGF\97states_recon.gdx', data_;
execute 'gdxxrw.exe i=..\Data\SGF\97states_recon.gdx o=..\Data\SGF\97states_recon.xlsx par=data_ rng=97sgf! rdim=1 cdim=1';

* ------------------------------------------------------------------------------
* Consolidate years of data:
* ------------------------------------------------------------------------------

$onecho >temp\gdxxrw.rsp
par=sgf1997 rdim=1 cdim=1
$offecho
$call 'gdxxrw i=..\Data\SGF\97states_recon.xlsx o=temp\gdx\97states.gdx trace=3 log=temp\97states.log maxdupeerrors=150 @temp\gdxxrw.rsp checkdate'

$onecho >temp\gdxxrw.rsp
par=sgf1998 rdim=1 cdim=1 rng=98stabs!a4 ignorerows=5 
$offecho
$call 'gdxxrw i=..\Data\SGF\98states.xls o=temp\gdx\98states.gdx trace=3 log=temp\98states.log maxdupeerrors=150 @temp\gdxxrw.rsp checkdate'

$onecho >temp\gdxxrw.rsp
par=sgf1999a rng=1!a3..bx64 rdim=1 cdim=1 ignorerows=6 
par=sgf1999b rng=2!a3..bx64 rdim=1 cdim=1 ignorerows=6 
$offecho
$call 'gdxxrw i=..\Data\SGF\99statess.xls o=temp\gdx\99statess.gdx trace=3 log=temp\99states.log maxdupeerrors=150 @temp\gdxxrw.rsp checkdate'

$onechov >temp\sgfxls.gms
$if not set yr $set yr 11
$if not set xls $set xls %yr%statess
$call 'gdxxrw i=..\Data\SGF\%xls%.xls o=temp\gdx\%xls%.gdx trace=3 log=temp\%xls%.log maxdupeerrors=150 epsout="-" naout="NA" par=sgf rng=a3..ex64 rdim=1 cdim=1 ignorerows=6'
parameter sgf(*,*);
$gdxin temp\gdx\%xls%.gdx 
$onundf
$loaddc sgf
$offecho

$if not exist '2011.gdx' $call gams temp\sgfxls --yr=11 gdx=temp\gdx\2011.gdx o=temp\lst\sgf2011.lst
$if not exist '2010.gdx' $call gams temp\sgfxls --yr=10 gdx=temp\gdx\2010.gdx o=temp\lst\sgf2010.lst
$if not exist '2009.gdx' $call gams temp\sgfxls --yr=09 gdx=temp\gdx\2009.gdx o=temp\lst\sgf2009.lst
$if not exist '2008.gdx' $call gams temp\sgfxls --yr=08 gdx=temp\gdx\2008.gdx o=temp\lst\sgf2008.lst
$if not exist '2007.gdx' $call gams temp\sgfxls --yr=07 gdx=temp\gdx\2007.gdx o=temp\lst\sgf2007.lst
$if not exist '2006.gdx' $call gams temp\sgfxls --yr=06 gdx=temp\gdx\2006.gdx o=temp\lst\sgf2006.lst
$if not exist '2005.gdx' $call gams temp\sgfxls --yr=05 gdx=temp\gdx\2005.gdx o=temp\lst\sgf2005.lst
$if not exist '2004.gdx' $call gams temp\sgfxls --yr=04 gdx=temp\gdx\2004.gdx o=temp\lst\sgf2004.lst
$if not exist '2003.gdx' $call gams temp\sgfxls --yr=03 gdx=temp\gdx\2003.gdx o=temp\lst\sgf2003.lst
$if not exist '2002.gdx' $call gams temp\sgfxls --yr=02 gdx=temp\gdx\2002.gdx o=temp\lst\sgf2002.lst
$if not exist '2001.gdx' $call gams temp\sgfxls --yr=01 gdx=temp\gdx\2001.gdx o=temp\lst\sgf2001.lst
$if not exist '2000.gdx' $call gams temp\sgfxls --yr=00 gdx=temp\gdx\2000.gdx o=temp\lst\sgf2000.lst
$call gdxmerge temp\gdx\20*.gdx output=temp\gdx\sgf2000s.gdx

set	yr /1997*2015/;
parameter	sgf(yr,*,*)		State government finances;
$gdxin 'temp\gdx\sgf2000s.gdx'
$onundf
$loaddc sgf

* Retrieve the earlier and later years:

parameter sgf1997(*,*);
$gdxin 'temp\gdx\97states.gdx'
$loaddc sgf1997

parameter sgf1998(*,*);
$gdxin 'temp\gdx\98states.gdx'
$loaddc sgf1998

parameter sgf1999a(*,*),sgf1999b(*,*);
$gdxin 'temp\gdx\99statess.gdx'
$loaddc sgf1999a sgf1999b

$call 'gdxxrw i=..\Data\SGF\SGF_2012_SGF001.csv o=temp\gdx\sgf_2012.gdx trace=3 log=temp\sgf2012.log par=sgf2012 rng="c1..be52" rdim=1 cdim=1'
parameter	sgf2012(*,sgfdata);
$gdxin 'temp\gdx\sgf_2012.gdx'
$loaddc sgf2012

$call 'gdxxrw i=..\Data\SGF\SGF_2013_SGF003.csv o=temp\gdx\sgf_2013.gdx trace=3 log=temp\sgf2013.log par=sgf2013 rng="c1..be52" rdim=1 cdim=1'
parameter	sgf2013(*,sgfdata);
$gdxin 'temp\gdx\sgf_2013.gdx'
$loaddc sgf2013

* 2014-2015 files of SGF data formatted differently:

$call 'gdxxrw i=..\Data\SGF\SGF_2014_00A1.csv o=temp\gdx\SGF_2014_00A1.gdx set=s rng=i2:i2245 rdim=1 par=sgf2014 rng=c2:j2245 rdim=7 cdim=0 maxdupeerrors=150'

$call 'gdxxrw i=..\Data\SGF\SGF_2015_00A1.csv o=temp\gdx\SGF_2015_00A1.gdx par=sgf2015 rng=c2:j2245 rdim=7 cdim=0'

set	ti	Truncated indices in datasets;

$gdxin 'temp\gdx\SGF_2014_00A1.gdx'
$loaddc ti=s

parameter	sgf2014(*,*,*,*,*,*,ti), sgf2015(*,*,*,*,*,*,ti);
alias (ii,jj,kk,i,j,b,*);
    
$loaddc sgf2014

$gdxin 'temp\gdx\SGF_2015_00A1.gdx'
$loaddc sgf2015

* Mapping:

set	map1415(sgfdata,ti) /
	SGF001."Total Revenue",
	SGF002."General Revenue",
	SGF003."Intergovernmental Revenue",
	SGF006."Total Taxes",
	SGF007."General Sales and Gross Receipts Taxes",
	SGF008."Selective Sales and Gross Receipts Taxes",
	SGF009."License Taxes",
	SGF010."Individual Income Taxes",
	SGF011."Corporation Net income Taxes",
	SGF012."All Other Taxes",
	SGF013."Current Charges",
	SGF014."Miscellaneous General Revenue",
	SGF015."Utility Revenue",
	SGF016."Liquor Stores Revenue",
	SGF017."Insurance Trust Revenue",
	SGF022."Total Expenditure",
	SGF023."Total Expenditure - Intergovernmental Expenditure",
	SGF024."Total Expenditure - Direct Expenditure",
	SGF025."Total Expenditure - Direct Expenditure - Current Operations",
	SGF026."Total Expenditure - Direct Expenditure - Capital Outlay",
	SGF029."Total Expenditure - Direct Expenditure - Interest on Debt",
	SGF032."Total Expenditure - General Expenditure",
	SGF036."General Expenditure, by Function: - Education",
	SGF037."General Expenditure, by Function: - Public Welfare",
	SGF038."General Expenditure, by Function: - Hospitals",
	SGF039."General Expenditure, by Function: - Health",
	SGF040."General Expenditure, by Function: - Highways",
	SGF041."General Expenditure, by Function: - Police Protection",
	SGF042."General Expenditure, by Function: - Correction",
	SGF043."General Expenditure, by Function: - Natural Resources",
	SGF044."General Expenditure, by Function: - Parks and Recreation",
	SGF045."General Expenditure, by Function: - Governmental Administration",
	SGF046."General Expenditure, by Function: - Interest on General Debt",
	SGF047."General Expenditure, by Function: - Other and Unallocable",
	SGF048."Utility Expenditure",
	SGF049."Liquor Stores Expenditure",
	SGF050."Insurance Trust Expenditure",
	SGF030."Total Expenditure - Exhibit: Salaries and Wages",
	SGF055."Total Debt Outstanding, Long term and Short Term",
	SGF056."Total Cash and Security Holdings",
	SGF027."Total Expenditure - Direct Expenditure - Insurance Benefits and",
	SGF028."Total Expenditure - Direct Expenditure - Assistance and Subsidi",
	SGF033."Total Expenditure - General Expenditure - Intergovernmental Gen",
	SGF034."Total Expenditure - General Expenditure - Direct General Expend"
	/;


alias (rid,rlabel,cid,clabel,*);

*	Merge the earlier data files:

loop((rid,cid)$sgf1999a(rid,cid),
	sgf("1999",rid,cid) = sgf1999a(rid,cid););
loop((rid,cid)$sgf1999b(rid,cid),
	sgf("1999",rid,cid) = sgf1999b(rid,cid););
loop((rid,cid)$sgf1998(rid,cid),
	sgf("1998",rid,cid) = sgf1998(rid,cid););

* 1997 is a bit different. Indices are already mapped.

*loop((rid,cid)$sgf1997(rid,cid),
*	sgf("1997",rid,cid) = sgf1997(rid,cid););

*	Merge the later data files:

loop((rid,sgfdata)$sgf2012(rid,sgfdata),
	sgf("2012",sgfdata,rid) = sgf2012(rid,sgfdata););
loop((rid,sgfdata)$sgf2013(rid,sgfdata),
	sgf("2013",sgfdata,rid) = sgf2013(rid,sgfdata););

set rowid(*), colid(*);  alias (rid,cid,*);
loop((yr,rid,cid)$sgf(yr,rid,cid), rowid(rid) = yes; colid(cid) = yes;);
option rowid:0:0:1, colid:0:0:1;
display rowid, colid;

set	rmap(sgfdata,rlabel) /
SGF001."Total Revenue"
SGF002."General revenue"
SGF003."Intergovernmental revenue"
SGF006."Taxes"
SGF007."General sales"
SGF008."Selective sales"
SGF009."License taxes"
SGF010."Individual income tax"
SGF011."Corporate income tax"
SGF012."Other taxes"
SGF013."Current charges"
SGF014."Miscellaneous general revenue"
SGF015."Utility revenue"
SGF016."Liquor store revenue"
SGF017."Insurance trust revenue"
SGF022."Total expenditure"
SGF023."Intergovernmental expenditure"
SGF024."Direct expenditure"
SGF025."Current operation"
SGF026."Capital outlay"
SGF027."Insurance benefits and repayments"
SGF028."Assistance and subsidies"
SGF029."Interest on debt"
SGF030."Exhibit: Salaries and wages"
SGF032."General expenditure"
SGF034."Direct expenditure"
SGF036."Education"
SGF037."Public welfare"
SGF038."Hospitals"
SGF039."Health"
SGF040."Highways"
SGF041."Police protection"
SGF042."Correction"
SGF043."Natural resources"
SGF044."Parks and recreation"
SGF045."Government administration"
SGF046."Interest on general debt"
SGF047."Other and unallocable"
SGF048."Utility expenditure"
SGF049."Liquor store expenditure"
SGF050."Insurance trust expenditure"
SGF055."Debt at end of fiscal year"
SGF056."Cash and security holdings" /;

rmap(sgfdata,sgfdata) = yes;

set cmap(states,clabel) /
	AL."ALABAMA",
	AK."ALASKA",
	AZ."ARIZONA",
	AR."ARKANSAS",
	CA."CALIFORNIA",
	CO."COLORADO",
	CT."CONNECTICUT",
	DE."DELAWARE",
	FL."FLORIDA",
	GA."GEORGIA",
	HI."HAWAII",
	ID."IDAHO",
	IL."ILLINOIS",
	IN."INDIANA",
	IA."IOWA",
	KS."KANSAS",
	KY."KENTUCKY",
	LA."LOUISIANA",
	ME."MAINE",
	MD."MARYLAND",
	MA."MASSACHUSETTS",
	MI."MICHIGAN",
	MN."MINNESOTA",
	MS."MISSISSIPPI",
	MO."MISSOURI",
	MT."MONTANA",
	NE."NEBRASKA",
	NV."NEVADA",
	NH."NEW HAMPSHIRE",
	NJ."NEW JERSEY",
	NM."NEW MEXICO",
	NY."NEW YORK",
	NC."NORTH CAROLINA",
	ND."NORTH DAKOTA",
	OH."OHIO",
	OK."OKLAHOMA",
	OR."OREGON",
	PA."PENNSYLVANIA",
	RI."RHODE ISLAND",
	SC."SOUTH CAROLINA",
	SD."SOUTH DAKOTA",
	TN."TENNESSEE",
	TX."TEXAS",
	UT."UTAH",
	VT."VERMONT",
	VA."VIRGINIA",
	WA."WASHINGTON",
	WV."WEST VIRGINIA",
	WI."WISCONSIN",
	WY."WYOMING" /;

set rdrop(*)	Rows to drop /
	"Population (thousands)",
	"Population (thousands, July 1, 1999)",
	"Personal income (millions, calendar year 1998)",
	"Population (thousands, April 1, 2000)",
	"Personal income (millions, calendar year 1999)",
	"Population (thousands, July 1, 2001)",
	"Personal income (millions, calendar year 2000)",
	"Population (thousands, July, 2002)",
	"Population (thousands, 2003)" /;

sgf(yr,rdrop,clabel) = 0;
sgf(yr,rlabel,"UNITED STATES") = 0;

parameter	sgf_(yr,states,sgfid)	Relabelled data;
loop((yr,rmap(sgfdata,rlabel),cmap(states,clabel))$sgf(yr,rlabel,clabel),
	loop(idmap(sgfid,sgfdata),
	  sgf_(yr,states,sgfid) = sgf(yr,rlabel,clabel); );
	sgf(yr,rlabel,clabel) = 0;);

sgf_(yr,states,sgfid)$(sgf_(yr,states,sgfid) = UNDF) = 0;

sgf_('1997',states,sgfid) = sum(idmap(sgfid,sgfdata), sgf1997(sgfdata,states));
sgf_('2014',states,sgfid) = sum(idmap(sgfid,sgfdata), sum((map1415(sgfdata,ti),cmap(states,clabel)), sum((ii,jj,kk,i,j), sgf2014(clabel,ii,jj,kk,i,j,ti))));
sgf_('2015',states,sgfid) = sum(idmap(sgfid,sgfdata), sum((map1415(sgfdata,ti),cmap(states,clabel)), sum((ii,jj,kk,i,j), sgf2015(clabel,ii,jj,kk,i,j,ti))));

parameter	nmissing	Number of missing states;
nmissing(sgfid) = sum(states$(sum(yr, abs(sgf_(yr,states,sgfid)))=0),1);
option nmissing:0;
display nmissing;

* Verify identities in the original data -- total expenditure and total revenue

set chk/chk1*chk8/;
set idsum(chk,sgfid,sgfid) /
	chk1.totrev.(genrev,utlrev,liqrev,insrev)
	chk2.genrev.(intrev,taxrev,curchg,mscrev)
	chk3.taxrev.(gsales,ssales,lictax,indtax,cortax,othtax),
	chk4.totexp.(intexp,direxp)
	chk5.genexp.(educat,pubwel,hosptl,health,hghway,police,
		correc,natres,parkrc,govadm,intgen,othuna),
	chk6.totexp.(genexp,utlexp,liqexp,insexp),
	chk7.insrev.(UNEMPL,PENSON,WRKCMP,OTHINS),
	chk8.intrev.(INTFED,INTLOC)/;

alias (sgfid,sid);

set sgftot(chk,sgfid)
loop(idsum(chk,sgfid,sid), sgftot(chk,sgfid) = yes;);

parameter chksum;
chksum(yr,states,sgftot(chk,sgfid),"diff")$sum(idsum(chk,sgfid,sid), sgf_(yr,states,sid))
	= sgf_(yr,states,sgfid) - sum(idsum(chk,sgfid,sid), sgf_(yr,states,sid));
chksum(yr,states,sgftot(chk,sgfid),"value") = sgf_(yr,states,sgfid);
option chksum:3:2:3;
display chksum;

* How big is each expenditure category?

set	ecat(sgfid) /
	EDUCAT	"Education"
	PUBWEL	"Public welfare"
	HOSPTL	"Hospitals"
	HEALTH	"Health"
	HGHWAY	"Highways"
	POLICE	"Police protection"
	CORREC	"Correction"
	NATRES	"Natural resources"
	PARKRC	"Parks and recreation"
	GOVADM	"Government administration"
	INTGEN	"Interest on general debt"
	OTHUNA	"Other and unallocable"
	UTLEXP	"Utility expenditure"
	LIQEXP	"Liquor store expenditure" /;
	
parameter	chkcat;
chkcat('1997',ecat) = sum(states, sgf_('1997',states,ecat));
chkcat('2014',ecat) = sum(states, sgf_('2014',states,ecat));
display chkcat;

execute_unload 'temp\gdx\sgf_raw.gdx',sgf_=sgf, yr, states, sgfid;
