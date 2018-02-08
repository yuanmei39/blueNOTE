$title Generate governmental expenditure shares

* Assume DC is the same as Maryland.

$if not set sectors 	$set sectors eng
$if not set year	$set year 2014

* Read in raw State Government Finances data (available on the census website),
* map to sector list and generate shares to use in disagg.gms.

set	r	Regions,
	ec	Government expenditure categories,
	yr	Years of data,
	g	Goods and sectors in core blueNOTE model /
$include 'defines\goodssectors_names_%sectors%.set'
/;

$gdxin 'temp\gdx\sgf_raw.gdx'
$loaddc r=states ec=sgfid yr

set	map(g,ec)	Mapping between SGF and blueNOTE indices /
$include 'defines\mapsgf_%sectors%.map'
/;

* Note that government expenditures in the model are treated
* indirectly. Most government administration expenditures are likely born by the
* production block of government related sectors. Thus, expenditures on public
* sector goods probably encompases public utility expenditures and the
* likes. That being said, I map many sectors to these singletons in the blueNOTE
* model to generate an index based on aggregated sectors.

parameter	sgf_raw(yr,r,ec)	Personal expenditure data,
		sgf_map(yr,*,g)		Mapped PCE data,
		sgf_shr(yr,*,g)		Regional shares of final consumption;

$loaddc sgf_raw=sgf

* Note that many of the sectors in blueNOTE are mapped to the same SGF
* category. Thus, sectors will have equivalent shares.

sgf_map(yr,r,g) = sum(map(g,ec), sgf_raw(yr,r,ec));

* DC is not represented in the SGF database. Assume similar expenditures as
* Maryland.

sgf_map(yr,'DC',g) = sgf_map(yr,'MD',g);

alias(i,*);

sgf_shr(yr,i,g)$sum(i.local, sgf_map(yr,i,g)) = sgf_map(yr,i,g) / sum(i.local, sgf_map(yr,i,g));

* For years: 1998, 2007, 2008, 2009, 2010, 2011, no government
* administration data is listed. In these cases, use all public
* expenditures (police, etc.).

sgf_shr(yr,i,g)$(sum(i.local, sgf_shr(yr,i,g)) = 0) = sgf_shr(yr,i,'fdd');

* Test, what do shares look like for %year%?

parameter	chkshr(g,r)	Check on SGF shares;
chkshr(g,r) = sgf_shr('%year%',r,g);
display chkshr;

abort$(round(smax(g, sum(r, chkshr(g,r))),6) ne 1) "Regional SGF shares don't sum to 1";

execute_unload "temp\gdx\sgfshares_%sectors%.gdx" sgf_shr;
