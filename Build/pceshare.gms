$title Generate PCE shares

$if not set sectors 	$set sectors eng
$if not set year	$set year 2014

* Read in raw PCE data, map to sector list and generate shares to use in
* disagg.gms.

set	r	Regions,
	pg	PCE goods,
	yr	Years of data,
	g	Goods and sectors in core blueNOTE model /
$include 'defines\goodssectors_names_%sectors%.set'
/;

$gdxin 'temp\gdx\pce_raw.gdx'
$loaddc r=s pg=g yr

set	map(g,pg)	Mapping between pce and blueNOTE indices /
$include 'defines\mappce_%sectors%.map'
/;

parameter	pce_raw(r,pg,yr)	Personal expenditure data,
		pce_map(r,g,yr)		Mapped PCE data,
		pce_shr(yr,r,g)		Regional shares of final consumption;

$loaddc pce_raw=pce

* Note that many of the sectors in blueNOTE are mapped to the same PCE
* category. Thus, sectors will have equivalent shares.

pce_map(r,g,yr) = sum(map(g,pg), pce_raw(r,pg,yr));
pce_shr(yr,r,g) = pce_map(r,g,yr) / sum(r.local, pce_map(r,g,yr));

* Test, what do shares look like for %year%?

parameter	chkshr(g,r)	Check on PCE shares;
chkshr(g,r) = pce_shr('%year%',r,g);
display chkshr;

abort$(round(smax(g, sum(r, chkshr(g,r))),6) ne 1) "Regional PCE shares don't sum to 1";

execute_unload "temp\gdx\pceshares_%sectors%.gdx" pce_shr;