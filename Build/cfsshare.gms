$title Generate Regional Purchase Coefficients based on CFS data

$if not set sectors 	$set sectors eng
$if not set year	$set year 2014

* Read in raw CFS data, map to sector list and generate RPCs to be used in
* disagg.gms.

set	sg	SCTG codes /
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

$call 'gdxxrw.exe i=..\Data\CFS\cfs_state_2012.xlsx o=temp\gdx\cfs_2012.gdx par=cfs2012 rng=data! rdim=4 cdim=0'
$gdxin 'temp\gdx\cfs_2012.gdx'
$loaddc cfs2012

set	r(*)	States in CFS data;

r(u) = yes$(not sameas(u,'Export') and sum((n,sg),cfs2012(u,u,n,sg)));

alias(r,rr);

parameter	d0_(*,n,sg)	State local supply,
		x0_(*,n,sg)	Export supply,
		mrt0_(*,*,n,sg)	Multi-regional trade;

d0_(r,n,sg) = cfs2012(r,r,n,sg);
x0_(r,n,sg) = cfs2012(r,"Export",n,sg);
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

parameter	d0(*,g)		Local supply-demand (CFS),
		x0(*,g)		Foreign exports (CFS),
		xn0(*,g)	National exports (CFS),
		mrt0(*,*,g)	Interstate trade (CFS),
		mn0(*,g)	National demand (CFS);

d0(r,g) = sum(map(sg,g), sum(n, d0_(r,n,sg)));
x0(r,g) = sum(map(sg,g), sum(n, x0_(r,n,sg)));
mrt0(r,rr,g) = sum(map(sg,g), sum(n, mrt0_(r,rr,n,sg)));
xn0(r,g) = sum(rr, mrt0(r,rr,g));
mn0(r,g) = sum(rr, mrt0(rr,r,g));

* Note that services and public sectors (i.e. utilities) are not included
* in the CFS data.

set	ng(g)	Sectors not included in the CFS;

ng(g) = yes$(sum(r, d0(r,g) + x0(r,g) + sum(rr, mrt0(r,rr,g))) = 0);
display ng;

* Without data need to make assumptions on inter-state trade. Assume most follow
* averages. Utilities represents a special case. Later when specifying RPCs,
* assume a 90% of utility demand come from local markets.

d0(r,ng) = (1/sum(g$(not ng(g)), 1)) * sum(g, d0(r,g));
x0(r,ng) = (1/sum(g$(not ng(g)), 1)) * sum(g, x0(r,g));
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

x0shr(r,g) = x0(r,g) / sum(r.local, x0(r,g));

* Assume states that export utilities are those on the border of the country.

set	b(*)	Border states
		/ AK, WA, ND, MN, NY, NH, ME, TX, NM, AZ, CA /;

x0shr(r,'ele_uti') = 0;
x0shr(r,'wat_uti') = 0;
x0shr(r,'gas_uti') = 0;

x0shr(b,'ele_uti') =  1 / sum(b.local, 1);
x0shr(b,'wat_uti') =  1 / sum(b.local, 1);
x0shr(b,'gas_uti') =  1 / sum(b.local, 1);

execute_unload 'temp\gdx\cfs_rpcs_%sectors%.gdx' rpc, x0shr;
