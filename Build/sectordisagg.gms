$title Routine for disaggregating sectoring definitions :/

$ontext
Roadmap for disaggregation routine:
 - read in fully disaggregate tables
 - formulate CGE parameters from disaggregated tables
 - generate a mapping to the 71 sector scheme
 - run matrix balancing routine to verify micro-consistency (making sure
   disaggregate numbers match aggregate totals)
 - define disaggregation scheme
 - output disaggregated parameters

Note -- I've only built in the renaming for eng and agr at the end of the
program. A total sector disaggregation or no disaggregation would result
in an error currently.

Define environment variable for sector disaggregation. Options built
into the routine:

 	eng = utilities and energy production
	agr = agricultural production
	tot = all sectors with exception to used and other goods
	non = no disaggregation

$offtext

$if not set sectors	$set sectors eng

* Stop routine if no sector disaggregation is needed:

$if %sectors%==non $exit

* -------------------------------------------------------------------
* 	Read in data from supply and use tables: (readbea.gms)
* -------------------------------------------------------------------

set 	ir_use		Numeric identifiers for use table rows /
$include '..\Data\BEA_2007\defines\naics_rowuse.set'
/,
 	jc_use		Numeric identifiers for use table columns /
$include '..\Data\BEA_2007\defines\naics_coluse.set'
/,
 	ir_supply	Numeric identifiers for supply table rows /
$include '..\Data\BEA_2007\defines\naics_rowsupply.set'
/,
 	jc_supply	Numeric identifiers for supply table columns /
$include '..\Data\BEA_2007\defines\naics_colsupply.set'
/;

$onecho >temp\gdxxrw.rsp
par=use2007 rng=2007!B6 rdim=1 cdim=1
$offecho

* Note: GAMS will truncate some of the set indices due to character
* length.

$call gdxxrw i="..\Data\BEA_2007\data\iouse_before_redefinitions_pur_2007_detail.xlsx" o="..\Data\BEA_2007\gdx\usetable_389sectors.gdx" @temp\gdxxrw.rsp

* Now pull the data with the labels:

$onecho >temp\gdxxrw.rsp
par=supply2007 rng=2007!B6 rdim=1 cdim=1
$offecho

$call gdxxrw i="..\Data\BEA_2007\data\IOMake_Before_Redefinitions_2007_Detail.xlsx" o="..\Data\BEA_2007\gdx\supplytable_389sectors.gdx" @temp\gdxxrw.rsp

parameter	use(ir_use,jc_use);

$gdxin '..\Data\BEA_2007\gdx\usetable_389sectors.gdx'
$loaddc use=use2007

parameter	supply(ir_supply,jc_supply);

$gdxin '..\Data\BEA_2007\gdx\supplytable_389sectors.gdx'
$loaddc supply=supply2007

* -------------------------------------------------------------------
* 	Scale and partition dataset: (partitionbea.gms)
* -------------------------------------------------------------------

* Scale input-output data to be in trillions of dollars:

use(ir_use,jc_use) = use(ir_use,jc_use) * 1e-4;
supply(ir_supply,jc_supply) = supply(ir_supply,jc_supply) * 1e-4;

set	i(*)	Goods and sectors  /
$include '..\Data\BEA_2007\defines\goodssectors.set'
/,
	va	Value-added /
$include '..\Data\BEA_2007\defines\valueadded.set'
/,
	fd	Final demand /
$include '..\Data\BEA_2007\defines\finaldemand.set'
/,
	ts	Taxes and subsidies /
$include '..\Data\BEA_2007\defines\taxessubsidies.set'
/;

alias (i,j);

parameter	ys0(j,i)	Sectoral supply
		fs0(i)		Household supply
		id0(i,j)	Intermediate demand
		fd0(i,fd)	Final demand,
		va0(va,j)	Vaue added,
		ts0(ts,j)	Taxes and subsidies
		m0(i)		Imports
		x0(i)		Exports of goods and services
		mrg0(i)		Trade margins
		trn0(i)		Transportation costs
		duty0(i)	Import duties
		sbd0(i)		Subsidies on products,
		tax0(i)		Taxes on products;

id0(i(ir_use),j(jc_use)) = use(ir_use,jc_use);
ys0(j(ir_supply),i(jc_supply)) = supply(ir_supply,jc_supply);

* Check water utilities:

parameter	watout;

watout(i,'watuti') = ys0('221300',i);
watout(i,'sle') = ys0('S00202',i) + ys0('S00203',i);

* Treat negative inputs as outputs:

ys0(j,i) = ys0(j,i) - min(0,id0(i,j));
id0(i,j) = max(0,id0(i,j));

fd0(i(ir_use),fd(jc_use)) = use(ir_use,jc_use);
va0(va(ir_use),j(jc_use)) = use(ir_use,jc_use);

* The following parameters aren't in the tables:

*ts0(ts(ir_use),j(jc_use)) = use(ir_use,jc_use);
*mrg0(i(ir_supply)) = supply(ir_supply,"margins");
*trn0(i(ir_supply)) = supply(ir_supply,"trncost");
*duty0(i(ir_supply)) = supply(ir_supply,"duties");
*tax0(i(ir_supply)) = supply(ir_supply,"tax");
*sbd0(i(ir_supply)) = supply(ir_supply,"subsidies");

x0(i(ir_use)) = use(ir_use,"F04000");
m0(i(ir_use)) = - use(ir_use,"F05000");

parameters	interm(j,*)		Total intermediate inputs (purchasers' prices),
		basicva(j,*)		Basic value added (purchasers' prices),
		valueadded(j,*)		Value added (purchaser's prices),
		output(j,*)		Total industry output (basic prices),
		taxtotal(*)		Check on total taxes,
		totint(i,*)		Total intermediate use (purchasers' prices),
		totaluse(i,*)		Total use of commodities (purchasers' prices),
		basicsupply(i,*)	Basic supply,
		tsupply(i,*)		Total supply;

interm(j(jc_use),"use") = use("T005",jc_use);
interm(j,"id0") = sum(i,id0(i,j));
interm(j,"chk") = interm(j,"id0") - interm(j,"use");
display interm;

* Sets with large positive differences are the result of eliminating
* negative input demands. Indicies with negative numbers for "chk"
* represent improper summing in the use tables supplied by the BEA. This
* is likely due to rounding upstream in their data routines. This latter
* point applies to other differences below (for value added, etc.).

valueadded(j(jc_use),"use") = use("T006",jc_use);
valueadded(j,"va0") = sum(va,va0(va,j));
valueadded(j,"chk") = valueadded(j,"use") - valueadded(j,"va0");

output(j(jc_use),"use") = use("T008",jc_use);
output(j,"id0+va0") = sum(va,va0(va,j)) + sum(i,id0(i,j));
output(j,"ys0") = sum(i,ys0(j,i));
output(j,"chk") = output(j,"id0+va0") - output(j,"use");
output(j,"chk-ys0") = output(j,"id0+va0") - output(j,"ys0");
display output;

totint(i(ir_use),"use") = use(ir_use,"T001");
totint(i,"id0") = sum(j,id0(i,j));
totint(i,"chk") = totint(i,"use") - totint(i,"id0");
display totint;

totaluse(i(ir_use),"use") = use(ir_use,"T007");
totaluse(i,"id0+fd0-m0") = sum(j,id0(i,j)) + sum(fd,fd0(i,fd)) + x0(i) - m0(i);
totaluse(i,"chk") = totaluse(i,"use") - totaluse(i,"id0+fd0-m0");
display totaluse;

parameter	y0(i)		Aggregate supply,
		a0(i)		Armington supply,
		bopdef		Balance of payments deficit;

bopdef = 0;
y0(j) = sum(i,ys0(i,j));

* Move household supply of recycled goods into the domestic output market
* from which some may be exported. Net out margin supply from output.

fs0(i) = -min(0, fd0(i,"F01000"));
y0(i) = sum(j,ys0(j,i)) + fs0(i);

parameter	details		Check on accounting identities;

details(i,"y0") = y0(i);
details(i,"m0") = m0(i);
details(i,"id0") = sum(j, id0(i,j));
details(i,"fd0") = sum(fd,fd0(i,fd));
details(i,"x0") = x0(i);

details(i,"balance") = y0(i) + m0(i) - sum(j, id0(i,j)) - sum(fd,fd0(i,fd)) - x0(i);
details(i,"marg + tax - sub") = y0(i) + m0(i) - sum(j, id0(i,j)) - sum(fd,fd0(i,fd)) - x0(i);

set	xfd(fd)		Exogenous components of final demand;

xfd(fd) = yes$(not sameas(fd,"F01000"));
a0(i) = sum(fd, fd0(i,fd)) + sum(j, id0(i,j));

* -------------------------------------------------------------------
* 	Map disaggregate sectoring scheme to aggregated scheme:
* -------------------------------------------------------------------

set	aggi		Aggregate sectoring scheme /
$include '..\Data\BEA_2007\defines\goodssectors_agg.set'
/,
	map(i,aggi)	Sectoring mapping /
$include '..\Data\BEA_2007\defines\goodssectors.map'
/,
	fd_nm		Non-numeric final demand indices,
	va_nm		Non-numeric value added indices;

alias(aggi,aggj);

* -------------------------------------------------------------------
* 	Read in aggregate 2007 data for approximation of unknowns:
* -------------------------------------------------------------------

set	m	Margins / trd	"Trade Margins", 
			  trn	"Transport Margins" /,
	yr	Year 	/ 1997*2015 /;

$gdxin 'temp\gdx/national_cgeparm_raw.gdx'
$loaddc fd_nm=fd va_nm=va

set	mapva(va,va_nm)	Mapping between naming - value added /
$include '..\Data\BEA_2007\defines\valueadded.map'
/,
	mapfd(fd,fd_nm)	Mapping between naming - final demand /
$include '..\Data\BEA_2007\defines\finaldemand.map'
/;

parameter	ys0_yr(yr,*,*), id0_yr(yr,*,*), fd0_yr(yr,*,fd_nm), va0_yr(yr,va_nm,*),
		fs0_yr(yr,*), y0_yr(yr,*), a0_yr(yr,*), x0_yr(yr,*), m0_yr(yr,*),
		md0_yr(yr,m,*), ms0_yr(yr,*,m), ta0_yr(yr,*), tm0_yr(yr,*);

$loaddc ys0_yr=ys0 id0_yr=id0 fd0_yr=fd0 va0_yr=va0
$loaddc fs0_yr=fs0 y0_yr=y0 a0_yr=a0 x0_yr=x0 m0_yr=m0
$loaddc md0_yr=md0 ms0_yr=ms0 ta0_yr=ta0 tm0_yr=tm0

* For parameters not in the disaggregate data, use equal shares:

parameter	ta0(i)		Output taxes,
		tm0(i)		Import taxes,
		md0(m,i)	Margin demand,
		ms0(i,m)	Margin supply,
		mdden		Margin demand denominator,
		msden		Margin supply denominator;

ta0(i) = sum(map(i,aggi), ta0_yr('2007',aggi));
tm0(i) = sum(map(i,aggi), tm0_yr('2007',aggi));

mdden(m,i) = sum(map(i,aggi), sum((i.local)$(map(i,aggi) and md0_yr('2007',m,aggi)), 1));
msden(m,i) = sum(map(i,aggi), sum((i.local)$(map(i,aggi) and ms0_yr('2007',aggi,m)), 1));
md0(m,i)$mdden(m,i) = (1/mdden(m,i)) * sum(map(i,aggi), md0_yr('2007',m,aggi));
ms0(i,m)$msden(m,i) = (1/msden(m,i)) * sum(map(i,aggi), ms0_yr('2007',aggi,m));

* -------------------------------------------------------------------
* 	Pick sectors to disaggregate:
* -------------------------------------------------------------------

* Generate an intermediate input report for electric power generation and
* natural gas distribution. Natural gas distribution likely is for heating
* purposes in homes and buildings. Not for fueling turbines at natural gas
* plants. Buy this directly.

* parameter	idelechk;

* idelechk(i) = id0(i,'221100');

* Report the top 10 inputs to electricity production:

* parameter 	rankdata(i)	Rank of each element,
* 		top10ele(i)	Top 10 inputs to electricity production;

* $libinclude rank idelechk i rankdata

* Note that the ranking is from smallest to largest.

* top10ele(i)$(card(i)-rankdata(i)<11) = idelechk(i);

$ontext
SectorID	Value	Description
324110		2.891 	"Petroleum refineries"
211000		2.527 	"Oil and gas extraction"
212100		0.824 	"Coal mining"
48A000		0.820 	"Support activities for transportation"
52A000		0.650 	"Monetary authorities and depository credit intermediation"
230301		0.594 	"Nonresidential maintenance and repair"
541100		0.525 	"Legal services"
5419A0		0.456 	"Miscellaneous professional services"
221300		0.308 	"Water, sewage and other systems"
561300		0.254 	"Employment services"
531ORE		0.246 	"Other real estate"
$offtext

* Oil and gas extraction is both natural gas production and crude oil
* production. Petroleum refineries deals with producing things like
* gasoline or other refined oils. Both crude and refined oil is used to
* generate electricity. Energy generation by fuel type, aggregate?

set	uti(i)	Utilities and Energy Production /
		221100	"Electric power generation, transmission, and distribution",
		221200	"Natural gas distribution",
		221300	"Water, sewage and other systems",
		324110	"Petroleum refineries"
		211000	"Oil and gas extraction"
		212100	"Coal mining" /,
	farm(i)	Agricultural Sectors /
		1111A0	"Oilseed farming",
		1111B0	"Grain farming",
		111200	"Vegetable and melon farming",
		111300	"Fruit and tree nut farming",
		111400	"Greenhouse, nursery, and floriculture production",
		111900	"Other crop farming",
		1121A0	"Beef cattle ranching and farming",
		112120	"Dairy cattle and milk production",
		112A00	"Animal production, except cattle and poultry and eggs",
		112300	"Poultry and egg production" /,
	als(i)	All sectors (exceptions -- used & other sectors);

* Refrain from disaggregating adjustment sectors:

als(i)= yes$(not sameas(i,'S00401') and not sameas(i,'S00402') and not sameas(i,'S00300') and not sameas(i,'S00900'));

* Note that in these disaggregation schemes, often we care about partially
* disaggregating the sectors (for instance, in energy production I only
* care about coal production, not iron and gold mining). Though this might
* be challenging. Perhaps the better route to take is pick the aggregate
* sector to disaggregate, and do so for all sub-sectors.

* Define aggregate sectors for disaggregation:
$ontext
set	eng(s)	Utilities and energy production /
		uti	"Utilities",
		oil	"Oil and gas extraction",
		min	"Mining, except oil and gas",
		pet	"Petroleum and coal products" /
	agr(s)	Agricultural production /
		agr	"Farms" /,
	tot(s)	All sectors (exceptions -- used & other sectors),
	non(s)	No sector disaggregation;

tot(s) = yes$(not sameas(s,'use') and not sameas(s,'oth'));
non(s) = no;
$offtext

set	eng(aggi)	Utilities and energy production /
			22	"Utilities"
			211	"Oil and gas extraction"
			212	"Mining, except oil and gas"
			324	"Petroleum and coal products" /,
	agr(aggi)	Agricultural production /
			111CA	"Farms" /,
	tot(aggi)	All sectors (exceptions -- used & other sectors),
	non(aggi)	No sector disaggregation;

tot(aggi) = yes$(not sameas(aggi,'Used') and not sameas(aggi,'Other'));
non(aggi) = no;

* ----------------------------------------------------------------
* 	Generate shares for disaggregation:
* ----------------------------------------------------------------

* Assume that the negative imports of gold and iron is a clerical mistake:

m0(i) = max(-m0(i),m0(i));

parameter	shares(aggi,*,i,*)	Single dimensional parameter shares,
		denom(aggi,*)		Denominator for shares;

* a0(i)		Armington supply,

denom(aggi,'a0') = sum(map(i,aggi), a0(i));
shares(aggi,' ',i,'a0')$(denom(aggi,'a0') and map(i,aggi) and %sectors%(aggi)) = a0(i) / denom(aggi,'a0');

* y0(i)		Gross output

denom(aggi,'y0') = sum(map(i,aggi), y0(i));
shares(aggi,' ',i,'y0')$(denom(aggi,'y0') and map(i,aggi) and %sectors%(aggi)) = y0(i) / denom(aggi,'y0');

* fs0(i)	Household supply

denom(aggi,'fs0') = sum(map(i,aggi), fs0(i));
shares(aggi,' ',i,'fs0')$(denom(aggi,'fs0') and map(i,aggi) and %sectors%(aggi)) = fs0(i) / denom(aggi,'fs0');

* m0(i)		Imports

denom(aggi,'m0') = sum(map(i,aggi), m0(i));
shares(aggi,' ',i,'m0')$(denom(aggi,'m0') and map(i,aggi) and %sectors%(aggi)) = m0(i) / denom(aggi,'m0');

* There are negative imports for one sector in the disaggregated
* dataset. Assume it was a clerical mistake.

* x0(i)		Exports of goods and services

denom(aggi,'x0') = sum(map(i,aggi), x0(i));
shares(aggi,' ',i,'x0')$(denom(aggi,'x0') and map(i,aggi) and %sectors%(aggi)) = x0(i) / denom(aggi,'x0');

parameter	denomii(aggi,*,*);

* fd0(i,fd)	Final demand,

denomii(aggi,fd,'fd0') = sum(map(i,aggi), fd0(i,fd));
shares(aggi,fd,i,'fd0')$(denomii(aggi,fd,'fd0') and map(i,aggi) and %sectors%(aggi)) = fd0(i,fd) / denomii(aggi,fd,'fd0');
shares(aggi,fd_nm,i,'fd0') = sum(mapfd(fd,fd_nm), shares(aggi,fd,i,'fd0'));
shares(aggi,fd,i,'fd0') = 0;

* va0(va,j)	Vaue added,

denomii(aggi,va,'va0') = sum(map(i,aggi), va0(va,i));
shares(aggi,va,i,'va0')$(denomii(aggi,va,'va0') and map(i,aggi) and %sectors%(aggi)) = va0(va,i) / denomii(aggi,va,'va0');
shares(aggi,va_nm,i,'va0') = sum(mapva(va,va_nm), shares(aggi,va,i,'va0'));
shares(aggi,va,i,'va0') = 0;

* md0(m,i)	Margin demand,

denomii(aggi,m,'md0') = sum(map(i,aggi), md0(m,i));
shares(aggi,m,i,'md0')$(denomii(aggi,m,'md0') and map(i,aggi) and %sectors%(aggi)) = md0(m,i) / denomii(aggi,m,'md0');

* ms0(i,m)	Margin supply,

denomii(aggi,m,'ms0') = sum(map(i,aggi), ms0(i,m));
shares(aggi,m,i,'ms0')$(denomii(aggi,m,'ms0') and map(i,aggi) and %sectors%(aggi)) = ms0(i,m) / denomii(aggi,m,'ms0');

* Maintain the same tax rates for disaggregate sectors:

* ta0(i)	Output taxes,

shares(%sectors%,' ',i,'ta0')$map(i,%sectors%) = 1;

* tm0(i)	Import taxes,

shares(%sectors%,' ',i,'tm0')$map(i,%sectors%) = 1;

* The following mutli-dimensional parameters require special treatment when
* sharing out data:

* ys0(j,i)	Sectoral supply

alias(map,mapp);

parameter	denomboth, sharesboth_, sharesboth;

denomboth(aggj,aggi,'j','ys0') = sum(map(i,aggi), sum(j$(mapp(j,aggj) and %sectors%(aggj)), ys0(j,i)));
denomboth(aggi,aggj,'i','ys0') = sum(map(j,aggi), sum(i$(mapp(i,aggj) and %sectors%(aggj)), ys0(j,i)));

sharesboth('j',aggj,j,aggi,'ys0')$(not %sectors%(aggi) and mapp(j,aggj)$%sectors%(aggj) and denomboth(aggj,aggi,'j','ys0')) =
		sum(map(i,aggi), ys0(j,i)) / denomboth(aggj,aggi,'j','ys0');

sharesboth('i',aggj,i,aggi,'ys0')$(not %sectors%(aggj) and map(i,aggi)$%sectors%(aggi) and denomboth(aggj,aggi,'i','ys0')) =
		sum(mapp(j,aggj), ys0(j,i)) / denomboth(aggj,aggi,'i','ys0');

sharesboth(aggj,j,aggi,i,'ys0')$(map(i,aggi)$%sectors%(aggi) and mapp(j,aggj)$%sectors%(aggj) and denomboth(aggj,aggi,'j','ys0')) =
		ys0(j,i) / denomboth(aggj,aggi,'j','ys0');

parameter	chkys0shr;
chkys0shr(aggj,aggi,'both') = sum((j,i), sharesboth(aggj,j,aggi,i,'ys0'));
chkys0shr(aggj,aggi,'j') = sum(j, sharesboth('j',aggj,j,aggi,'ys0'));
chkys0shr(aggj,aggi,'i') = sum(i, sharesboth('i',aggj,i,aggi,'ys0'));

* id0(j,i)	Intermediate demand

denomboth(aggj,aggi,'j','id0') = sum(map(i,aggi), sum(j$(mapp(j,aggj) and %sectors%(aggj)), id0(j,i)));
denomboth(aggi,aggj,'i','id0') = sum(map(j,aggi), sum(i$(mapp(i,aggj) and %sectors%(aggj)), id0(j,i)));

sharesboth('j',aggj,j,aggi,'id0')$(not %sectors%(aggi) and mapp(j,aggj)$%sectors%(aggj) and denomboth(aggj,aggi,'j','id0')) =
		sum(map(i,aggi), id0(j,i)) / denomboth(aggj,aggi,'j','id0');

sharesboth('i',aggj,i,aggi,'id0')$(not %sectors%(aggj) and mapp(i,aggi)$%sectors%(aggi) and denomboth(aggj,aggi,'i','id0')) =
		sum(mapp(j,aggj), id0(j,i)) / denomboth(aggj,aggi,'i','id0');

sharesboth(aggj,j,aggi,i,'id0')$(map(i,aggi)$%sectors%(aggi) and mapp(j,aggj)$%sectors%(aggj) and denomboth(aggj,aggi,'j','id0')) =
		id0(j,i) / denomboth(aggj,aggi,'j','id0');

parameter	chkid0shr;
chkid0shr(aggj,aggi,'both') = sum((j,i), sharesboth(aggj,j,aggi,i,'id0'));
chkid0shr(aggj,aggi,'j') = sum(j, sharesboth('j',aggj,j,aggi,'id0'));
chkid0shr(aggj,aggi,'i') = sum(i, sharesboth('i',aggj,i,aggi,'id0'));
display chkid0shr;

* ----------------------------------------------------------------
* 	Create master set for all included indices:
* ----------------------------------------------------------------

* Output a master set for all included sets in the analysis to share out
* two dimensional parameters:

set	gi(*)	Master set of goods and sectors in disaggregation;

gi(aggi) = yes;
gi(aggi)$%sectors%(aggi) = no;

* Rename added i sectors. I'm going to punt on this one a bit. Only do the
* renaming for the energy and agricultural sectors due to limited time.

set	ni	Named i indices /
$include ..\Data\BEA_2007\defines\%sectors%.set
/,
	mapni(ni,i)	Mapped indices /
$include ..\Data\BEA_2007\defines\%sectors%.map
/;

alias(ni,mj),(%sectors%,s%sectors%), (mapni,mapmj);

gi(ni) = yes$(sum(mapni(ni,i), sum(%sectors%(aggi), map(i,aggi))));

* ----------------------------------------------------------------
* 	Share out aggregate data:
* ----------------------------------------------------------------

a0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'a0')) * a0_yr(yr,%sectors%));
a0_yr(yr,%sectors%) = 0;
y0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'y0')) * y0_yr(yr,%sectors%));
y0_yr(yr,%sectors%) = 0;
m0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'m0')) * m0_yr(yr,%sectors%));
m0_yr(yr,%sectors%) = 0;
x0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'x0')) * x0_yr(yr,%sectors%));
x0_yr(yr,%sectors%) = 0;
md0_yr(yr,m,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,m,i,'md0')) * md0_yr(yr,m,%sectors%));
md0_yr(yr,m,%sectors%) = 0;

parameter	neng 	Non-energy sectors;

neng(aggi) = 1;
neng(%sectors%) = 0;
neng(ni) = 0;

* Define the output matrix:

ys0_yr(yr,aggi,ni)$neng(aggi) = sum(%sectors%, sum(mapni(ni,j), sharesboth('i',aggi,j,%sectors%,'ys0')) * ys0_yr(yr,aggi,%sectors%));
ys0_yr(yr,ni,aggi)$neng(aggi) = sum(%sectors%, sum(mapni(ni,j), sharesboth('j',%sectors%,j,aggi,'ys0')) * ys0_yr(yr,%sectors%,aggi));
ys0_yr(yr,ni,mj) = sum((%sectors%,s%sectors%), sum((mapni(ni,i),mapmj(mj,j)), sharesboth(%sectors%,i,s%sectors%,j,'ys0')) * ys0_yr(yr,%sectors%,s%sectors%));

* Define the intermediate input matrix:

id0_yr(yr,aggi,ni)$(neng(aggi)=1) = sum(%sectors%, sum(mapni(ni,j), sharesboth('i',aggi,j,%sectors%,'id0')) * id0_yr(yr,aggi,%sectors%));
id0_yr(yr,ni,aggi)$(neng(aggi)=1) = sum(%sectors%, sum(mapni(ni,j), sharesboth('j',%sectors%,j,aggi,'id0')) * id0_yr(yr,%sectors%,aggi));
id0_yr(yr,ni,mj) = sum((%sectors%,s%sectors%), sum((mapni(ni,i),mapmj(mj,j)), sharesboth(%sectors%,i,s%sectors%,j,'id0')) * id0_yr(yr,%sectors%,s%sectors%));

$ontext
* Perform some diagnostic calculations:

set	s(*);
s(aggi) = yes;
s(ni) = yes;
alias(s,g);

parameter	ys0oil, id0oil;

ys0oil(g,'tot') = ys0_yr('2007','211',g);
ys0oil(g,'dis') = ys0_yr('2007','oil_oil',g);
id0oil(g,'tot') = id0_yr('2007',g,'211');
id0oil(g,'dis') = id0_yr('2007',g,'oil_oil');
display ys0oil, id0oil;
$offtext

ys0_yr(yr,aggi,%sectors%) = 0;
ys0_yr(yr,%sectors%,aggi) = 0;
ys0_yr(yr,%sectors%,s%sectors%) = 0;

id0_yr(yr,aggi,%sectors%) = 0;
id0_yr(yr,%sectors%,aggi) = 0;
id0_yr(yr,%sectors%,s%sectors%) = 0;

* Final demand and value added. Negative shares for fd0:

shares(%sectors%,fd_nm,i,'fd0') = max(-shares(%sectors%,fd_nm,i,'fd0'),shares(%sectors%,fd_nm,i,'fd0'));
fd0_yr(yr,ni,fd_nm) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,fd_nm,i,'fd0')) * fd0_yr(yr,%sectors%,fd_nm));
fd0_yr(yr,%sectors%,fd_nm) = 0;

va0_yr(yr,va_nm,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,va_nm,i,'va0')) * va0_yr(yr,va_nm,%sectors%));
va0_yr(yr,va_nm,%sectors%) = 0;

* The following don't have energy related things to share out, though are
* included for completeness.

fs0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'fs0')) * fs0_yr(yr,%sectors%));
fs0_yr(yr,%sectors%) = 0;
ms0_yr(yr,ni,m) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,m,i,'ms0')) * ms0_yr(yr,%sectors%,m));
ms0_yr(yr,%sectors%,m) = 0;

* Tax rates are maintained from aggregated data:

ta0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'ta0')) * ta0_yr(yr,%sectors%));
ta0_yr(yr,%sectors%) = 0;
tm0_yr(yr,ni) = sum(%sectors%, sum(mapni(ni,i), shares(%sectors%,' ',i,'tm0')) * tm0_yr(yr,%sectors%));
tm0_yr(yr,%sectors%) = 0;

* ----------------------------------------------------------------
* 	Output disaggregated data:
* ----------------------------------------------------------------

execute_unload 'temp\gdx\sectordisagg.gdx' yr,m,gi,ni,mapni,i,aggi,va_nm,fd_nm,%sectors%,aggi,shares,sharesboth,ys0_yr,id0_yr,fd0_yr,va0_yr,fs0_yr,y0_yr,a0_yr,x0_yr,m0_yr,md0_yr,ms0_yr,ta0_yr,tm0_yr,ta0_yr,tm0_yr;