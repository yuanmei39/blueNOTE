$title Generate Regional Purchase Coefficients based on CFS data

$if not set sectors 	$set sectors eng
$if not set year	$set year 2014

* Read in raw CFS data, map to sector list and generate RPCs to be used in
* disagg.gms.

set	r	Regions,
	sg	SCTG codes /
$include 'defines\cfs_sctg.set'
/,
	n	NAICS codes /
$include 'defines\cfs_naics.set'
/,
	g	Goods and sectors in core blueNOTE model /
$include 'defines\goodssectors_names_%sectors%.set'
/;

* First two indices in CFS parameter correspond to regions. "Export" is part of
* this list.

alias(*,u);
parameter	cfs2012(*,*,n,sg)	CFS data for 2012;

$gdxin '..\Data\CFS\cfsdata_2012.gdx'
$loaddc cfs2012=cfsdata_st
$loaddc r

alias(r,rr);

parameter	d0_(r,n,sg)	State local supply,
		mrt0_(r,r,n,sg)	Multi-regional trade;

d0_(r,n,sg) = cfs2012(r,r,n,sg);
mrt0_(r,rr,n,sg)$(not sameas(r,rr)) = cfs2012(r,rr,n,sg);

* Map to model indices -- use SCTG codes. Trade is through goods markets. Note
* that the mapping includes double counting. In some instances there
* are many to one, and in other there are one to many. The point is to get
* a sense of shares.

set	map(sg,g) /
$include 'defines\cfsmap_%sectors%.map'
/;

* Note that blueNOTE uses the RPC in the Armington nest. Therefore, I need to
* capture all goods coming IN from other states (net imports -- here we care
* only for sub-national trade).

parameter	d0(r,g)		Local supply-demand (CFS),
		xn0(r,g)	National exports (CFS),
		mrt0(r,r,g)	Interstate trade (CFS),
		mn0(r,g)	National demand (CFS);

d0(r,g) = sum(map(sg,g), sum(n, d0_(r,n,sg)));
mrt0(r,rr,g) = sum(map(sg,g), sum(n, mrt0_(r,rr,n,sg)));
xn0(r,g) = sum(rr, mrt0(r,rr,g));
mn0(r,g) = sum(rr, mrt0(rr,r,g));

* Note that services and public sectors (i.e. utilities) are not included
* in the CFS data.

set	ng(g)	Sectors not included in the CFS;

ng(g) = yes$(sum(r, d0(r,g) + sum(rr, mrt0(r,rr,g))) = 0);
display ng;

* Without data need to make assumptions on inter-state trade. Assume most follow
* averages. Utilities represents a special case. Later when specifying RPCs,
* assume a 90% of utility demand come from local markets.

d0(r,ng) = (1/sum(g$(not ng(g)), 1)) * sum(g, d0(r,g));
xn0(r,ng) = (1/sum(g$(not ng(g)), 1)) * sum(g, xn0(r,g));
mn0(r,ng) = (1/sum(g$(not ng(g)), 1)) * sum(g, mn0(r,g));

* Define a region-good pairing's RPC as the local share of total subnational
* demand:

parameter	rpc(*,g)	Regional purchase coefficient,
		x0shr(*,g)	Export shares supply;

rpc(r,g)$(d0(r,g) + mn0(r,g)) = d0(r,g) / (d0(r,g) + mn0(r,g));

* Utility specific regional purchase coefficient:

rpc(r,'ele_uti') = 0.9;
rpc(r,'wat_uti') = 0.9;
rpc(r,'gas_uti') = 0.9;

execute_unload 'temp\gdx\cfs_rpcs_%sectors%.gdx' rpc;
