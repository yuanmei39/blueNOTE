$title Regional Disaggregation of the National IO Tables

* Output data directory is specified here:
$if not set dsdir 	$set dsdir datasets\

$if not set sectors	$set sectors eng
$if not set year 	$set year 2014

* -------------------------------------------------------------------
* Read in the national dataset:
* -------------------------------------------------------------------

set	yr	Years of IO data,
	r	States,
	s	Goods\sectors (national data),
 	m	Margins (trade or transport),
	fd	Final demand categories,
	va	Value added components;

$gdxin 'temp\gdx\nationaldata_%sectors%.gdx'
$loaddc yr s=i va fd m
alias(s,g,ss,gg),(r,rr);

parameter	y_0(yr,s)	Gross output
		ys_0(yr,g,s)	Sectoral supply
		fs_0(yr,s)	Household supply
		id_0(yr,s,g)	Intermediate demand
		fd_0(yr,s,fd)	Final demand,
		va_0(yr,va,s)	Vaue added,
		m_0(yr,s)	Imports
		x_0(yr,s)	Exports of goods and services
		ms_0(yr,s,m)	Margin supply,
		md_0(yr,m,s)	Margin demand,
		s_0(yr,s)	Aggregate supply,
		a_0(yr,s)	Armington supply,
		ta_0(yr,s)	Tax net subsidy rate on intermediate demand,
		tm_0(yr,s)	Import tariff,
		bopdef_0(yr)	Balance of payments;

$loaddc y_0 ys_0 fs_0 id_0 fd_0 va_0 m_0 x_0
$loaddc ms_0 md_0 s_0 a_0 bopdef_0 ta_0 tm_0

* From here on out, don't include 2015:

set	yy(yr)	Years with reliable data;

yy(yr) = yes$(not sameas(yr,'2015'));

* -------------------------------------------------------------------
* Read in shares generated using state level gross product, pce, cfs and
* government expenditures:
* -------------------------------------------------------------------

parameter	regionshare(yr,r,s)	Regional shares based on GSP,
		laborshare(yr,r,s)	Labor share of GSP,
		pceshare(yr,r,g)	Regional shares based on PCE,
		sgfshare(yr,r,g)	Regional government expenditure shares (SGF),
		cfs_rpc(r,g)		Regional purchase coefficients based on CFS (2012),
		xmshare(yr,r,g,*)	Regional export-import shares based on USA Trade Online;

set		notrd(g)		Sectors not included in USA Trade Online;

$gdxin 'temp\gdx\gspshares_%sectors%.gdx'
$loaddc r regionshare laborshare

$gdxin 'temp\gdx\pceshares_%sectors%.gdx'
$loaddc pceshare=pce_shr

$gdxin 'temp\gdx\sgfshares_%sectors%.gdx'
$loaddc sgfshare=sgf_shr

$gdxin 'temp\gdx\cfs_rpcs_%sectors%.gdx'
$loaddc cfs_rpc=rpc

$gdxin 'temp\gdx\usatrdshares_%sectors%.gdx'
$loaddc xmshare=usatrdshr notrd=notinc

* How do shares differ? Look at example:

parameter	diffshr(g,*)	Check on share differences;

diffshr(g,'PCE') = pceshare('%year%','WI',g);
diffshr(g,'SGF') = sgfshare('%year%','WI',g);
diffshr(g,'GSP') = regionshare('%year%','WI',g);
diffshr(g,'Labor') = laborshare('%year%','WI',g);
diffshr(g,'RPC') = cfs_rpc('WI',g);
diffshr(g,'Xpt') = xmshare('%year%','WI',g,'exports');
diffshr(g,'Imp') = xmshare('%year%','WI',g,'imports');

* For years not included in USA Trade Online shares, use most recent
* shares. Earliest year for exports is: 2002. Earliest year for imports
* is: 2008.

xmshare(yr,r,g,'exports')$(ord(yr) < 6) = xmshare('2002',r,g,'exports');
xmshare(yr,r,g,'imports')$(ord(yr) < 12) = xmshare('2008',r,g,'imports');

* Verify all shares both sum to 1 and are in [0,1]:

parameter	shrverify	Verify consistent shares;

shrverify(yy,g,'PCE','max') = smax(r, pceshare(yy,r,g));
shrverify(yy,g,'SGF','max') = smax(r, sgfshare(yy,r,g));
shrverify(yy,g,'GSP','max') = smax(r, regionshare(yy,r,g));
shrverify(yy,g,'LABOR','max') = smax(r, laborshare(yy,r,g));
shrverify(yy,g,'RPC','max') = smax(r, cfs_rpc(r,g));
shrverify(yy,g,'XPT','max') = smax(r, xmshare(yy,r,g,'exports'));
shrverify(yy,g,'IMP','max') = smax(r, xmshare(yy,r,g,'imports'));

shrverify(yy,g,'PCE','min') = smin(r$pceshare(yy,r,g), pceshare(yy,r,g));
shrverify(yy,g,'SGF','min') = smin(r$sgfshare(yy,r,g), sgfshare(yy,r,g));
shrverify(yy,g,'GSP','min') = smin(r$regionshare(yy,r,g), regionshare(yy,r,g));
shrverify(yy,g,'LABOR','min') = smin(r$laborshare(yy,r,g), laborshare(yy,r,g));
shrverify(yy,g,'RPC','min') = smin(r$cfs_rpc(r,g), cfs_rpc(r,g));
shrverify(yy,g,'XPT','min') = smin(r$xmshare(yy,r,g,'exports'), xmshare(yy,r,g,'exports'));
shrverify(yy,g,'IMP','min') = smin(r$xmshare(yy,r,g,'imports'), xmshare(yy,r,g,'imports'));

shrverify(yy,g,'PCE','sum') = sum(r, pceshare(yy,r,g));
shrverify(yy,g,'SGF','sum') = sum(r, sgfshare(yy,r,g));
shrverify(yy,g,'GSP','sum') = sum(r, regionshare(yy,r,g));
shrverify(yy,g,'XPT','sum') = sum(r, xmshare(yy,r,g,'exports'));
shrverify(yy,g,'IMP','sum') = sum(r, xmshare(yy,r,g,'imports'));

display shrverify;

* -------------------------------------------------------------------
* Regionalize production data using iomacro shares and GSP data:
* -------------------------------------------------------------------

parameter	va0_(yr,r,s)	Regional value added,
		ld0_(yr,r,s)	Labor demand,
		kd0_(yr,r,s)	Capital demand,
		y0_(yr,r,s)	Regional gross sectoral output,
		ys0_(yr,r,s,g)	Regional sectoral output,
		id0_(yr,r,s,g)	Regional intermediate demand,
		zprof(yr,r,s)	Check on ZP;

ys0_(yy,r,s,g) = regionshare(yy,r,s) * ys_0(yy,s,g);
id0_(yy,r,g,s) = regionshare(yy,r,s) * id_0(yy,g,s);
va0_(yy,r,s) = regionshare(yy,r,s) * sum(va, va_0(yy,va,s));

* Split aggregate value added based on GSP components:

ld0_(yy,r,s) = laborshare(yy,r,s) * va0_(yy,r,s);
kd0_(yy,r,s) = va0_(yy,r,s) - ld0_(yy,r,s);

zprof(yy,r,s) = sum(g, ys0_(yy,r,s,g)) - ld0_(yy,r,s) - kd0_(yy,r,s) - sum(g, id0_(yy,r,g,s));
abort$(smax((yy,r,s), abs(zprof(yy,r,s))) > 1e-5) "Error in zero profit check in regionalization.";

* -------------------------------------------------------------------
* Final demand categories:
* -------------------------------------------------------------------

* Aggregate final demand categories:

set	fdcat		Aggregated final demand categories /
			C			"Household consumption",
			I			"Investment",
			G			"Government expenditures" /,

	fdmap(fd,fdcat)	Mapping of final demand /
			pce.C			"Personal consumption expenditures"
			structures.I	"Nonresidential private fixed investment in structures"
			equipment.I		"Nonresidential private fixed investment in equipment"
			intelprop.I		"Nonresidential private fixed investment in intellectual"
			residential.I	"Residential private fixed investment"
			changinv.I		"Change in private inventories"
			defense.G		"National defense: Consumption expenditures"
			def_structures.G	"Federal national defense: Gross investment in structures"
			def_equipment.G	"Federal national defense: Gross investment in equipment"
			def_intelprop.G	"Federal national defense: Gross investment in intellectual"
			nondefense.G	"Nondefense: Consumption expenditures"
			fed_structures.G	"Federal nondefense: Gross investment in structures"
			fed_equipment.G	"Federal nondefense: Gross investment in equipment"
			fed_intelprop.G	"Federal nondefense: Gross investment in intellectual property p"
			state_consume.G	"State and local government consumption expenditures"
			state_invest.G	"State and local: Gross investment in structures"
			state_equipment.G "State and local: Gross investment in equipment"
			state_intelprop.G "State and local: Gross investment in intellectual" /;

parameter	g_0(yr,g)	National government demand,
		i_0(yr,g)	National investment demand,
		cd_0(yr,g)	National final consumption,
		yh0_(yr,r,s)	Household production,
		fe0_(yr,r)	Total factor supply,
		cd0_(yr,r,s)	Consumption demand,
		c0_(yr,r)	Total final household consumption,
		i0_(yr,r,s)	Investment demand,
		g0_(yr,r,s)	Government demand;

g_0(yy,g) = sum(fdmap(fd,'g'), fd_0(yy,g,fd));
i_0(yy,g) = sum(fdmap(fd,'i'), fd_0(yy,g,fd));
cd_0(yy,g) = sum(fdmap(fd,'c'), fd_0(yy,g,fd));

yh0_(yy,r,s) = fs_0(yy,s) * regionshare(yy,r,s);
fe0_(yy,r) = sum(s, va0_(yy,r,s));

* Use PCE and government demand data rather than regionshare:

cd0_(yy,r,g) = pceshare(yy,r,g) * cd_0(yy,g);
g0_(yy,r,g) = sgfshare(yy,r,g) * g_0(yy,g);
i0_(yy,r,g) = regionshare(yy,r,g) * i_0(yy,g);
c0_(yy,r) = sum(s, cd0_(yy,r,s));

* --------------------------------------------------------------------------
* Trade parameters:
* --------------------------------------------------------------------------

parameters	m0_(yr,r,s)	Foreign Imports,
		md0_(yr,r,m,s)	Margin demand,
		ms0_(yr,r,s,m)	Margin supply,
		x0_(yr,r,s)	Foreign Exports,
		s0_(yr,r,s)	Total supply,
		bopdef0_(yr,r)	Balance of payments (closure parameter),
		a0_(yr,r,s)	Domestic absorption,
		tm0_(yr,r,s)	Import taxes,
		ta0_(yr,r,s)	Absorption taxes,
		tr0a_(yr,r,s)	Tax revenue from output,
		tr0m_(yr,r,s)	Tax revenue on imports,
		rx0_(yr,r,s)	Re-exports;

* Use export shares from USA Trade Online for included sectors. For those
* not included, use gross state product shares:

x0_(yy,r,s) = xmshare(yy,r,s,'exports') * x_0(yy,s);
x0_(yy,r,s)$notrd(s) = regionshare(yy,r,s) * x_0(yy,s);

* No longer subtracting margin supply from gross output. This will be allocated
* through the national and local markets.

s0_(yy,r,s) = sum(g, ys0_(yy,r,g,s)) + yh0_(yy,r,s);
a0_(yy,r,g) = cd0_(yy,r,g) + g0_(yy,r,g) + i0_(yy,r,g) + sum(s, id0_(yy,r,g,s));

tm0_(yy,r,s) = tm_0(yy,s);
ta0_(yy,r,s) = ta_0(yy,s);

parameter	thetaa(yr,r,g)	Share of regional absorption;

thetaa(yy,r,g)$sum(r.local, (1-ta0_(yy,r,g))*a0_(yy,r,g)) = a0_(yy,r,g) / sum(r.local, a0_(yy,r,g));
m0_(yy,r,g) = thetaa(yy,r,g) * m_0(yy,g);
md0_(yy,r,m,g) = thetaa(yy,r,g) * md_0(yy,m,g);

* Note that s0_ - x0_ is negative for the other category. md0 is zero for that
* category and: a + x = s + m. This means that some part of the other goods
* imports are directly re-exported. Note, re-exports are defined as the maximum
* between s0_-x0_ and the zero profit condition for the Armington
* composite. This is due to balancing issues when defining domestic and national
* demands. Particularly in the other goods sector which is a composite of the
* "fudge" factor in the national IO accounts.

rx0_(yy,r,g)$(round(s0_(yy,r,g) - x0_(yy,r,g),10) < 0) = x0_(yy,r,g) - s0_(yy,r,g);

* The 'oth' sector is problematic with negative numbers. Treat as
* re-exports.

parameter	diffrx0		Negative numbers still exist due to sharing parameter;

diffrx0(yy,r,g) = - min(round((1-ta0_(yy,r,g))*a0_(yy,r,g) + rx0_(yy,r,g) -
    			((1+tm0_(yy,r,g))*m0_(yy,r,g) + sum(m, md0_(yy,r,m,g))),10), 0);

rx0_(yy,r,g) = rx0_(yy,r,g) + diffrx0(yy,r,g)$s0_(yy,r,g);
bopdef0_(yy,r) = sum(g, m0_(yy,r,g) - x0_(yy,r,g));

set	gm(g)		Commodities employed in margin supply;

gm(g) = yes$(sum((yy,m), ms_0(yy,g,m)) or sum((yy,m), md_0(yy,m,g)));

parameters	xn0_(yr,r,g)	Regional supply to national market,
		xd0_(yr,r,g)	Regional supply to local market,
		dd0_(yr,r,g)	Regional demand from local market,
		dd0min(yr,r,g)	Minimum regional demand from local market,
		dd0max(yr,r,g)	Maximum regional demand from local market,
		nd0_(yr,r,g)	Regional demand from national market
		nd0min(yr,r,g)	Minimum regional demand from national market,
		nd0max(yr,r,g)	Maximum regional demand from national market,
		nm0_(yr,r,m,g)	Margin demand from the national market,
		dm0_(yr,r,m,g)	Margin supply from the local market;

* Assume domestic demand is defined by either the supply or demand side of the
* market. Maximum or minimum amound would depend on level of national imports
* and exports.

dd0max(yy,r,g) = min(round((1-ta0_(yy,r,g))*a0_(yy,r,g) + rx0_(yy,r,g) -
    			((1+tm0_(yy,r,g))*m0_(yy,r,g) + sum(m, md0_(yy,r,m,g))),10),
    		      round(s0_(yy,r,g) - (x0_(yy,r,g) - rx0_(yy,r,g)),10) );

nd0max(yy,r,g) = min(round((1-ta0_(yy,r,g))*a0_(yy,r,g) + rx0_(yy,r,g) -
    			((1+tm0_(yy,r,g))*m0_(yy,r,g) + sum(m, md0_(yy,r,m,g))),10),
    		      round(s0_(yy,r,g) - (x0_(yy,r,g) - rx0_(yy,r,g)),10) );

* We can subsequently define nd0min and xd0min as:

nd0min(yy,r,g) = (1-ta0_(yy,r,g))* a0_(yy,r,g) + rx0_(yy,r,g) - dd0max(yy,r,g) - m0_(yy,r,g)*(1+tm0_(yy,r,g)) - sum(m,md0_(yy,r,m,g));
dd0min(yy,r,g) = (1-ta0_(yy,r,g))* a0_(yy,r,g) + rx0_(yy,r,g) - nd0max(yy,r,g) - m0_(yy,r,g)*(1+tm0_(yy,r,g)) - sum(m,md0_(yy,r,m,g));

* The mixture of domestic vs. national demand in the absorption market is
* determined by regional purchase coefficients. Use estimates based on 2012
* Commodity Flow Survey data:

parameter	rpc(yr,r,g)	Regional purchase coefficients;

rpc(yy,r,g) = cfs_rpc(r,g);
dd0_(yy,r,g) = rpc(yy,r,g) * dd0max(yy,r,g);
nd0_(yy,r,g) = round((1-ta0_(yy,r,g))*a0_(yy,r,g) + rx0_(yy,r,g) - dd0_(yy,r,g) - m0_(yy,r,g)*(1+tm0_(yy,r,g)) - sum(m,md0_(yy,r,m,g)),10);

* Assume margins come both from local and national production. Assign like
* dd0. Use information on national margin supply to enforce other identities.

parameter	totmargsupply(yr,r,m,g)		Designate total supply of margins,
		margshr(yr,r,m)			Share of margin demand by region,
		shrtrd(yr,r,m,g)		Share of margin total by margin type;

margshr(yy,r,m)$sum((g,rr), md0_(yy,rr,m,g)) = sum(g, md0_(yy,r,m,g)) / sum((g,rr), md0_(yy,rr,m,g));
totmargsupply(yy,r,m,g) = margshr(yy,r,m) * ms_0(yy,g,m);
shrtrd(yy,r,m,gm)$sum(m.local, totmargsupply(yy,r,m,gm)) = totmargsupply(yy,r,m,gm) / sum(m.local, totmargsupply(yy,r,m,gm));
dm0_(yy,r,m,gm) = min(rpc(yy,r,gm)*totmargsupply(yy,r,m,gm), shrtrd(yy,r,m,gm)*(s0_(yy,r,gm) - x0_(yy,r,gm) + rx0_(yy,r,gm) - dd0_(yy,r,gm)));
nm0_(yy,r,m,gm) = totmargsupply(yy,r,m,gm) - dm0_(yy,r,m,gm);

* Regional and national output must then be tied down as follows:

xd0_(yy,r,g) = sum(m, dm0_(yy,r,m,g)) + dd0_(yy,r,g);
xn0_(yy,r,g) = round(s0_(yy,r,g) + rx0_(yy,r,g) - xd0_(yy,r,g) - x0_(yy,r,g),10);

* Check equilibrium conditions:

parameter	zp, mkt, ibal;

zp(yy,r,s,'Y') = sum(g, ys0_(yy,r,s,g)) - sum(g, id0_(yy,r,g,s)) - ld0_(yy,r,s) - kd0_(yy,r,s);
zp(yy,r,g,'A') = (1-ta0_(yy,r,g))*a0_(yy,r,g) + rx0_(yy,r,g) -
	(nd0_(yy,r,g) + dd0_(yy,r,g) + (1+tm0_(yy,r,g))*m0_(yy,r,g) + sum(m, md0_(yy,r,m,g)));
zp(yy,r,g,'X') = s0_(yy,r,g) - xd0_(yy,r,g) - xn0_(yy,r,g) - x0_(yy,r,g) + rx0_(yy,r,g);
zp(yy,r,m,'M') = sum(s, nm0_(yy,r,m,s) + dm0_(yy,r,m,s)) - sum(g, md0_(yy,r,m,g));

ibal(yy,r,'inc') = sum(s, va0_(yy,r,s) + yh0_(yy,r,s)) + bopdef0_(yy,r) - sum(s, g0_(yy,r,s) + i0_(yy,r,s));
ibal(yy,r,'taxrev') = sum(s, ta0_(yy,r,s) * a0_(yy,r,s) + tm0_(yy,r,s)*m0_(yy,r,s));
ibal(yy,r,'expend') = c0_(yy,r);
ibal(yy,r,'balance') = ibal(yy,r,'expend') - ibal(yy,r,'inc') - ibal(yy,r,'taxrev');
ibal(yy,'USA','balance') = sum(r, ibal(yy,r,'balance'));

* Need a household adjustment:

parameter	hhadj_(yr,r)	Household adjustment parameter;

hhadj_(yy,r) = ibal(yy,r,'balance');

mkt(yy,r,g,'PA') = a0_(yy,r,g) -
    	(sum(s, id0_(yy,r,g,s)) + cd0_(yy,r,g) + g0_(yy,r,g) + i0_(yy,r,g));
mkt(yy,'USA',g,'PN')$(not sameas(yy,'2015')) = sum(r, xn0_(yy,r,g)) - sum((r,m), nm0_(yy,r,m,g)) - sum(r, nd0_(yy,r,g));
mkt(yy,r,g,'PY') = sum(s, ys0_(yy,r,s,g)) + yh0_(yy,r,g) - s0_(yy,r,g);
mkt(yy,'USA','all','PFX') = sum(r, sum(s, x0_(yy,r,s)) + hhadj_(yy,r) + bopdef0_(yy,r)) - sum((r,s), m0_(yy,r,s));

* -------------------------------------------------------------------
* Verify there are no negative numbers for %year%:
* -------------------------------------------------------------------

alias(p,*);

parameter	negnum;

negnum('ys0') = smin((r,g,s), ys0_('%year%',r,g,s));
negnum('id0') = smin((r,s,g), id0_('%year%',r,s,g));
negnum('ld0') = smin((r,s), ld0_('%year%',r,s));
negnum('kd0') = smin((r,s), kd0_('%year%',r,s));
negnum('m0') = smin((r,g), m0_('%year%',r,g));
negnum('x0') = smin((r,g), x0_('%year%',r,g));
negnum('rx0') = smin((r,g), rx0_('%year%',r,g));
negnum('md0') = smin((r,m,gm), md0_('%year%',r,m,gm));
negnum('nm0') = smin((r,m,gm), nm0_('%year%',r,m,gm));
negnum('dm0') = smin((r,m,gm), dm0_('%year%',r,m,gm));
negnum('s0') = smin((r,g), s0_('%year%',r,g));
negnum('a0') = smin((r,g), a0_('%year%',r,g));
negnum('cd0') = smin((r,g), cd0_('%year%',r,g));
negnum('c0') = smin((r), c0_('%year%',r));
negnum('yh0') = smin((r,g), yh0_('%year%',r,g));
negnum('g0') = smin((r,g), g0_('%year%',r,g));
negnum('i0') = smin((r,g), i0_('%year%',r,g));
negnum('xn0') = smin((r,g), xn0_('%year%',r,g));
negnum('xd0') = smin((r,g), xd0_('%year%',r,g));
negnum('dd0') = smin((r,g), dd0_('%year%',r,g));
negnum('nd0') = smin((r,g), nd0_('%year%',r,g));

abort$(smin(p, negnum(p)) < 0) "Negative numbers exist in regionalized parameters.";

* -------------------------------------------------------------------
* Check microconsistency in a regional accounting model for %year%:
* -------------------------------------------------------------------

$include 'statemodel.gms'
statemodel.workspace = 100;
statemodel.iterlim = 0;
$include temp\statemodel.gen
solve statemodel using mcp;
abort$(statemodel.objval>1e-5) "Error in benchmark calibration with regional data.";

* -------------------------------------------------------------------
* Output regionalized dataset:
* -------------------------------------------------------------------

* We include _ at the end of each parameter name to indicate all years of data
* are included.

execute_unload '%dsdir%blueNOTE_%sectors%.gdx' 

* Sets:

yr,r,s,m,gm,

* Production data: 

ys0_,ld0_,kd0_,id0_,

* Consumption data:

yh0_,fe0_,cd0_,c0_,i0_,g0_,bopdef0_,hhadj_,

* Trade data:

s0_,xd0_,xn0_,x0_,rx0_,a0_,nd0_,dd0_,m0_,ta0_,tm0_,

* Margins:

md0_,nm0_,dm0_;