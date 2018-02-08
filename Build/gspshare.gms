$title Share Generation Based On State Level Gross Product

$ontext
See Data directory for stata code on reading GSP data (see
stategdp.do). Suppress shares for 2015 due to data inavailability.
$offtext

$if not set sectors	$set sectors eng

* -------------------------------------------------------------------
* Read in state level GSP data:
* -------------------------------------------------------------------

set	yr	Years,
    	r	States,
	si	State industry list,
	gdpcat	GSP components;

$gdxin 'temp\gdx\gsp_raw.gdx'
$loaddc yr r gdpcat si=s

parameter	gsp(r,yr,gdpcat,si)	Annual gross state product;

$loaddc gsp

* Note: GSP ne lab + cap + tax in the data for government affiliated sectors
* (utilities, enterprises, etc.).

parameter	gspcalc(r,yr,gdpcat,si)	Calculated gross state product;

gspcalc(r,yr,'cmp',si) = gsp(r,yr,'cmp',si);
gspcalc(r,yr,'gos',si) = gsp(r,yr,'gos',si);
gspcalc(r,yr,'taxsbd',si) = gsp(r,yr,'taxsbd',si);
gspcalc(r,yr,'gdp',si) = gspcalc(r,yr,'cmp',si) + gspcalc(r,yr,'gos',si) + gspcalc(r,yr,'taxsbd',si);

* Note that some capital account elements of GSP are negative (taxes and
* capital expenditures).

* -------------------------------------------------------------------
* Map GSP sectors to national IO definitions:
* -------------------------------------------------------------------

* Note that in the mapping, aggregate categories in the GSP dataset are
* removed. Also, the used and other sectors don't have any mapping to the
* state files. In cases other than used and other, the national files have
* more detail. In cases where multiple sectors are mapped to the state gdp
* estimates, the same profile of GDP will be used. Used and scrap sectors
* are defined by state averages.

set	s		Non-numeric goods-sector definitions,
	i		Raw goods-sector definition from BEA;

$gdxin 'temp\gdx\nationaldata_%sectors%.gdx'
$loaddc s=i i=s

set	mapseci(si,i)	Mapping between state sectors and national sectors /
$include 'defines\gspsecmap_%sectors%.map'
/
	mapis(i,s)	Mapping between non-numeric and BEA definitions /
$include "defines\goodssectors_names_%sectors%.map"
/;

parameter	gsp0(yr,r,s,*)		Mapped state level gsp accounts,
		gspcat0(yr,r,s,gdpcat)	Mapped gsp categorical accounts;

gsp0(yr,r,s,'Calculated') = sum(mapis(i,s), sum(mapseci(si,i), gspcalc(r,yr,'gdp',si)));
gsp0(yr,r,s,'Reported') = sum(mapis(i,s), sum(mapseci(si,i), gsp(r,yr,'gdp',si)));
gsp0(yr,r,s,'Diff') = gsp0(yr,r,s,'Calculated') - gsp0(yr,r,s,'Reported');

gspcat0(yr,r,s,gdpcat) = sum(mapis(i,s), sum(mapseci(si,i), gsp(r,yr,gdpcat,si)));

* For the most part, these figures match (rounding errors produce +-1 on the
* check). However, sector 10 other government affiliated sectors (utilities)
* produces larger error.

* -------------------------------------------------------------------
* Generate io-shares using national data to share out regional GDP
* estimates, first mapping data to state level aggregation:
* -------------------------------------------------------------------

parameter	regionshare	Regional share of value added,
		laborshare	Share of regional value added due to labor,
		netva		Net value added (compensation + surplus);

regionshare(yr,r,s)$(sum(r.local, gsp0(yr,r,s,'Reported')) and not sameas(yr,'2015')) = gsp0(yr,r,s,'Reported') / sum(r.local,  gsp0(yr,r,s,'Reported'));

* Let used, scrap and other retail sectors be an average of other sectors:

regionshare(yr,r,'use')$sum((r.local,s), regionshare(yr,r,s)) = sum(s, regionshare(yr,r,s)) / sum((r.local,s), regionshare(yr,r,s));
regionshare(yr,r,'oth')$sum((r.local,s), regionshare(yr,r,s)) = sum(s, regionshare(yr,r,s)) / sum((r.local,s), regionshare(yr,r,s));
regionshare(yr,r,'ott')$sum((r.local,s), regionshare(yr,r,s)) = sum(s, regionshare(yr,r,s)) / sum((r.local,s), regionshare(yr,r,s));

* Verify regional shares sum to one:

regionshare(yr,r,s)$sum(r.local, regionshare(yr,r,s)) = regionshare(yr,r,s) / sum(r.local, regionshare(yr,r,s));

* Define labor component of value added demand:

netva(yr,r,s) = gspcat0(yr,r,s,'cmp') + gspcat0(yr,r,s,'gos');
laborshare(yr,r,s)$netva(yr,r,s) = gspcat0(yr,r,s,'cmp') / netva(yr,r,s);

* At least 1 year for a given region-sector pairing has wage shares less than 1:

set	hw(r,s)	Regions with all years of high wage shares;
hw(r,s) = yes$(smin(yr, laborshare(yr,r,s))>1);

* Pick out (year,region,sector) pairings with wage shares greater than 1.

set	wg(yr,r,s)	Index pairs with high wage shares;
wg(yr,r,s) = yes$(laborshare(yr,r,s)>1);

* Take an average for a given region-sector across years with shares less
* than 1.

parameter	avgwgshr(r,s)	Average wage share;

avgwgshr(r,s) = (1/sum(yr$(not wg(yr,r,s)), 1)) * sum(yr$(not wg(yr,r,s)), laborshare(yr,r,s));
laborshare(yr,r,s)$wg(yr,r,s) = avgwgshr(r,s);

parameter	chkshrs		Check on regional shares;
chkshrs(yr,s) = sum(r, regionshare(yr,r,s));

abort$(round(smin((yr,s)$(not sameas(yr,'2015')), chkshrs(yr,s))) ne 1) "Missing GSP shares.";
abort$(round(smax((yr,r,s)$(not sameas(yr,'2015')), laborshare(yr,r,s))) ne 1) "Missing GSP shares.";

* -------------------------------------------------------------------
* Output regional shares:
* -------------------------------------------------------------------

execute_unload 'temp\gdx\gspshares_%sectors%.gdx' regionshare,laborshare,r;