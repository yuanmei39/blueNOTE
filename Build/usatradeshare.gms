$title GAMS routine for merging USA Trade Online data into build

$if not set sectors	$set sectors eng

* Note that exports are available from 2002-2016, while imports are
* available from 2008-2012.

set	n	NAICS codes /
$include 'defines\usatrade_naics.set'
/,
	r	States /
$include 'defines\states.set'
/,
	yr	Years / 2002*2016 /,
	t	Trade type /imports, exports/;

parameter	usatrd(r,n,yr,t)	Trade data;

$call 'gdxxrw.exe i=..\Data\USATradeOnline\statetrade.xlsx o=temp\gdx\usatrade.gdx par=usatrd rng=data!A1 rdim=3 cdim=1';
$gdxin 'temp\gdx\usatrade.gdx'
$loaddc usatrd

* Data originally in millions of dollars. Scale to 10s of billions:

usatrd(r,n,yr,t) = usatrd(r,n,yr,t) * 1e-4;

* Create mapping to model indices:

set	s	Model indices for sectors /
$include 'defines\goodssectors_names_%sectors%.set'
/,
	map(n,s)	Mapping between naics codes and sectors /
$include 'defines\usatrdmapping_%sectors%.map'
/,
	ioyr(yr)	Years with IO data / 2002*2014 /;

parameter	usatrd_(yr,r,s,t)	Mapped trade data,
		usatrdshr(yr,r,s,t)	Share of total trade by region;

usatrd_(ioyr,r,s,t) = sum(map(n,s), usatrd(r,n,ioyr,t));

* Which sectors are not mapped? Could be there just aren't any
* imports/exports for a given sector region pairing or the sector isn't
* included (services/utilities). For exports, it would make more sense to
* differentiate sectors not included based on state gross product for a
* given state.

set	notinc(s)	Sectors not included in USA Trade Data;

notinc(s) = yes$(not sum(n, map(n,s)));
usatrdshr(ioyr,r,s,t)$(not notinc(s) and sum(r.local, usatrd_(ioyr,r,s,t))) = usatrd_(ioyr,r,s,t) / sum(r.local, usatrd_(ioyr,r,s,t));

* Note that there isn't data for all years for the publishing sector in
* both exports and imports. Take average of data:

usatrdshr(ioyr,r,s,t)$(not notinc(s) and not sum(r.local, usatrd_(ioyr,r,s,t))) = sum(ioyr.local, usatrd_(ioyr,r,s,t)) / sum((r.local,ioyr.local), usatrd_(ioyr,r,s,t));

* Perform a comparison between import and export shares:

parameter	shrchk		Comparison between imports and exports;

shrchk(s,t) = usatrdshr('2014','CA',s,t);

* Verify all shares sum to 1:

abort$(smax((ioyr,s), round(sum(r, usatrdshr(ioyr,r,s,'exports')), 4)) ne 1) "Export shares don't sum to 1.";
abort$(smax((ioyr,s), round(sum(r, usatrdshr(ioyr,r,s,'imports')), 4)) ne 1) "Import shares don't sum to 1.";

execute_unload 'temp\gdx\usatrdshares_%sectors%.gdx' usatrdshr, notinc;