$title Partition IO data in CGE Parameters

* -------------------------------------------------------------------
* 	Read in dataset:
* -------------------------------------------------------------------

set	yr	Years in the dataset
		/1997*2015/;

sets	ir_use(*), ir_supply(*), jc_use(*), jc_supply(*);

$gdxin 'temp\gdx\national_mapiotable.gdx'
$load ir_use ir_supply jc_use jc_supply
 
parameter	use(yr,ir_use,jc_use)		Annual use matrix
		supply(yr,ir_supply,jc_supply)	Annual supply matrix;

$loaddc use supply

* -------------------------------------------------------------------
* 	Scale and partition dataset:
* -------------------------------------------------------------------

* Scale input-output data to be in 10s of billions of dollars.

use(yr,ir_use,jc_use) = use(yr,ir_use,jc_use) * 1e-4;
supply(yr,ir_supply,jc_supply) = supply(yr,ir_supply,jc_supply) * 1e-4;

set	i(*)	Goods and sectors  /
$include 'defines/goodssectors.set'
/,
	va	Value-added /
$include 'defines/valueadded.set'
/,
	fd	Final demand /
$include 'defines/finaldemand.set'
/,
	ts	Taxes and subsidies /
$include 'defines/taxessubsidies.set'
/;

alias (i,j);

parameter	y0(yr,i)		"Gross output",
		ys0(yr,j,i)		"Sectoral supply",
		fs0(yr,i)		"Household supply",
		id0(yr,i,j)		"Intermediate demand",
		fd0(yr,i,fd)	"Final demand,",
		va0(yr,va,j)	"Vaue added,",
		ts0(yr,ts,j)	"Taxes and subsidies",
		m0(yr,i)		"Imports",
		x0(yr,i)		"Exports of goods and services",
		mrg0(yr,i)		"Trade margins",
		trn0(yr,i)		"Transportation costs",
		duty0(yr,i)		"Import duties",
		sbd0(yr,i)		"Subsidies on products,",
		tax0(yr,i)		"Taxes on products";

id0(yr,i(ir_use),j(jc_use)) = use(yr,ir_use,jc_use);
ys0(yr,j(jc_supply),i(ir_supply)) = supply(yr,ir_supply,jc_supply);

* Treat negative inputs as outputs:

ys0(yr,j,i) = ys0(yr,j,i) - min(0,id0(yr,i,j));
id0(yr,i,j) = max(0,id0(yr,i,j));
fd0(yr,i(ir_use),fd(jc_use)) = use(yr,ir_use,jc_use);
va0(yr,va(ir_use),j(jc_use)) = use(yr,ir_use,jc_use);
ts0(yr,ts(ir_use),j(jc_use)) = use(yr,ir_use,jc_use);
m0(yr,i(ir_supply)) = supply(yr,ir_supply,"imports");
mrg0(yr,i(ir_supply)) = supply(yr,ir_supply,"margins");
trn0(yr,i(ir_supply)) = supply(yr,ir_supply,"trncost");
duty0(yr,i(ir_supply)) = supply(yr,ir_supply,"duties");
tax0(yr,i(ir_supply)) = supply(yr,ir_supply,"tax");
sbd0(yr,i(ir_supply)) = supply(yr,ir_supply,"subsidies");
x0(yr,i(ir_use)) = use(yr,ir_use,"exports");

* Remove commodity taxes and subsidies on the goods which
* are produced solely for supplying retail sales margin:

set	imrg(i)		Goods which only generate margins /
			441	"Motor vehicle and parts dealers"
			445	"Food and beverage stores"
			452	"General merchandise stores" /;

tax0(yr,imrg) = 0;
sbd0(yr,imrg) = 0;

y0(yr,i) = sum(j, ys0(yr,j,i));

parameters	interm(yr,j,*)		Total intermediate inputs (purchasers' prices),
		basicva(yr,j,*)		Basic value added (purchasers' prices),
		valueadded(yr,j,*)	Value added (purchaser's prices),
		output(yr,j,*)		Total industry output (basic prices),
		taxtotal(yr,*)		Check on total taxes,
		totint(yr,i,*)		Total intermediate use (purchasers' prices),
		totaluse(yr,i,*)	Total use of commodities (purchasers' prices),
		basicsupply(yr,i,*)	Basic supply,
		tsupply(yr,i,*)		Total supply;

interm(yr,j(jc_use),"use") = use(yr,"interm",jc_use);
interm(yr,j,"id0") = sum(i,id0(yr,i,j));
interm(yr,j,"chk") = interm(yr,j,"id0") - interm(yr,j,"use");
display interm;

* Sets with large positive differences are the result of eliminating
* negative input demands. Indicies with negative numbers for "chk"
* represent improper summing in the use tables supplied by the BEA. This
* is likely due to rounding upstream in their data routines. This latter
* point applies to other differences below (for value added, etc.).

basicva(yr,j(jc_use),"use") = use(yr,"basicvalueadded",jc_use);
basicva(yr,j,"va0") = sum(va,va0(yr,va,j));
basicva(yr,j,"chk") = basicva(yr,j,"use") - basicva(yr,j,"va0");
display basicva;

valueadded(yr,j(jc_use),"use") = use(yr,"valueadded",jc_use);
valueadded(yr,j,"va0+ts0") = sum(va,va0(yr,va,j)) + 
			ts0(yr,"taxes",j) - ts0(yr,"subsidies",j);
valueadded(yr,j,"chk") = valueadded(yr,j,"use") - valueadded(yr,j,"va0+ts0");
display valueadded;

taxtotal(yr,"ts_subsidies") = sum(j, ts0(yr,"subsidies",j));
taxtotal(yr,"ts_taxes") = sum(j, ts0(yr,"taxes",j));
taxtotal(yr,"s0") = sum(i,sbd0(yr,i));
taxtotal(yr,"t0+duty") = sum(i,tax0(yr,i)+duty0(yr,i));
display taxtotal;

* Differences in subsidy totals from zeroing out taxes and subsidies for
* margin only sectors.

output(yr,j(jc_use),"use") = use(yr,"industryoutput",jc_use);
output(yr,j,"id0+va0") = sum(va,va0(yr,va,j)) + sum(i,id0(yr,i,j));
output(yr,j,"ys0") = sum(i,ys0(yr,j,i));
output(yr,j,"chk") = output(yr,j,"id0+va0") - output(yr,j,"use");
output(yr,j,"chk-ys0") = output(yr,j,"id0+va0") - output(yr,j,"ys0");
display output;

totint(yr,i(ir_use),"use") = use(yr,ir_use,"totint");
totint(yr,i,"id0") = sum(j,id0(yr,i,j));
totint(yr,i,"chk") = totint(yr,i,"use") - totint(yr,i,"id0");
display totint;

totaluse(yr,i(ir_use),"use") = use(yr,ir_use,"totaluse");
totaluse(yr,i,"id0+fd0") = sum(j,id0(yr,i,j)) + sum(fd,fd0(yr,i,fd)) + x0(yr,i);
totaluse(yr,i,"chk") = totaluse(yr,i,"use") - totaluse(yr,i,"id0+fd0");
display totaluse;

basicsupply(yr,i(ir_supply),"supply") = supply(yr,ir_supply,"BasicSupply");
basicsupply(yr,i,"ys0") = sum(j,ys0(yr,j,i));
basicsupply(yr,i,"chk") = basicsupply(yr,i,"supply") - basicsupply(yr,i,"ys0");
display basicsupply;

tsupply(yr,i(ir_supply),"supply") = supply(yr,ir_supply,"Supply");
tsupply(yr,i,"ys0+...") = sum(j,ys0(yr,j,i))
	+ m0(yr,i) + mrg0(yr,i) + trn0(yr,i) + duty0(yr,i) + tax0(yr,i) - sbd0(yr,i);
tsupply(yr,i,"totaluse") = sum(j,id0(yr,i,j)) + sum(fd,fd0(yr,i,fd)) + x0(yr,i);
tsupply(yr,i,"chk") = tsupply(yr,i,"supply") - tsupply(yr,i,"totaluse");
tsupply(yr,i,"supply-use") = tsupply(yr,i,"ys0+...") - tsupply(yr,i,"totaluse");
display tsupply;

set	m	Margins /trd,trn/;

parameter	ms0(yr,i,m)	Margin supply,
		md0(yr,m,i)	Margin demand,
		s0(yr,i)	Aggregate supply,
		d0(yr,i)	Sales in the domestic market,
		a0(yr,i)	Armington supply,
		bopdef(yr)	Balance of payments deficit;

bopdef(yr) = 0;
s0(yr,j) = sum(i,ys0(yr,i,j));
ms0(yr,i,"trd") = max(-mrg0(yr,i),0);
ms0(yr,i,"trn") = max(-trn0(yr,i),0);
md0(yr,"trd",i) = max(mrg0(yr,i),0);
md0(yr,"trn",i) = max(trn0(yr,i),0);

* Move household supply of recycled goods into the domestic output market
* from which some may be exported. Net out margin supply from output.

fs0(yr,i) = -min(0, fd0(yr,i,"pce"));
y0(yr,i) = sum(j,ys0(yr,j,i)) + fs0(yr,i) - sum(m,ms0(yr,i,m));

parameter	details		Check on accounting identities;

details(yr,i,"y0") = y0(yr,i);
details(yr,i,"m0") = m0(yr,i) + duty0(yr,i);
details(yr,i,"mrg+trn") = mrg0(yr,i) + trn0(yr,i);
details(yr,i,"tax-sbd") = tax0(yr,i)-sbd0(yr,i);
details(yr,i,"id0") = sum(j, id0(yr,i,j));
details(yr,i,"fd0") = sum(fd,fd0(yr,i,fd));
details(yr,i,"x0") = x0(yr,i);
details(yr,i,"balance") = y0(yr,i)+m0(yr,i)+duty0(yr,i) + tax0(yr,i)-sbd0(yr,i) 
	- sum(j, id0(yr,i,j)) - sum(fd,fd0(yr,i,fd)) - x0(yr,i)
		+ (mrg0(yr,i) + trn0(yr,i));
display details;

set	xfd(fd)		Exogenous components of final demand;

xfd(fd) = yes$(not sameas(fd,"pce"));

* Optional projection methods for determining value shares:

$ontext
set kl(ir_use) /compen,surplus/;

parameter	vshare		Value shares, 
		outputval	Value of output;

outputval(yr,j(jc_supply)) = sum(ir_supply, supply(yr,ir_supply,jc_supply));

vshare("baseline",yr,kl(ir_use),j(jc_use))$outputval(yr,j)
	 = use(yr,ir_use,jc_use)/outputval(yr,j);

vshare("baseline",yr,"va",j(jc_use))$outputval(yr,j)
	 = sum(kl(ir_use),use(yr,ir_use,jc_use))/outputval(yr,j);

variables	OBJ, ALPHA, BETA, GAMMA, V;
equations objdef, vdef, zerobound, stability;

objdef..	OBJ =e= sum((j,kl), sum(yr, sqr(V(yr,kl,j)-vshare("baseline",yr,kl,j))));

vdef(yr,kl,j)..	V(yr,kl,j) =e= ALPHA(kl,j) + (yr.val-1997)*BETA(kl,j) + sqr(yr.val-1997)*GAMMA(kl,j);

set yrpt/2015*2097/;

zerobound(kl,j,yrpt)..	ALPHA(kl,j) + (yrpt.val-1997)*BETA(kl,j) + sqr(yrpt.val-1997)*GAMMA(kl,j) =g= 0;

stability(kl,j,yrpt)..	ALPHA(kl,j) + (yrpt.val-1997)*BETA(kl,j) + sqr(yrpt.val-1997)*GAMMA(kl,j) =l= smax(yr,vshare("baseline",yr,kl,j));

model lsqr /all/;

$if not set vaadjust $set vaadjust yes
if (%vaadjust%,

	lsqr.savepoint = 1;
$if exist lsqr_p.gdx execute_loadpoint 'lsqr_p.gdx';
	solve lsqr using nlp minimizing OBJ;
	vshare("trend",yr,kl,j) = V.L(yr,kl,j);
	vshare("trend",yrpt,kl,j) = ALPHA.L(kl,j) + (yrpt.val-1997)*BETA.L(kl,j) + sqr(yrpt.val-1997)*GAMMA.L(kl,j);

*.execute_unload 'vshare.gdx',vshare;
*.execute 'gdxxrw i=vshare.gdx o=vshare.xlsx par=vshare rng=PivotData!a2 cdim=0';

*	Assign capital and labor use as no less than half
*	the long-term value:

	va0(va(kl),j) = max(va0(va,j),0.5*vshare("trend","%yr%",kl,j)) * outputval("%yr%",j);
);
$offtext

a0(yr,i) = sum(fd, fd0(yr,i,fd)) + sum(j, id0(yr,i,j));

* Verify that goods that which only produce margins have zero entries
* elsewhere:

parameter	imrginfo	Report of margin producing sectors;

imrginfo(yr,"a0",imrg) = a0(yr,imrg);
imrginfo(yr,"tax0",imrg) = tax0(yr,imrg);
imrginfo(yr,"sbd0",imrg) = sbd0(yr,imrg);
imrginfo(yr,"x0",imrg) = x0(yr,imrg);
imrginfo(yr,"m0",imrg) = m0(yr,imrg);
imrginfo(yr,"duty0",imrg) = duty0(yr,imrg);
imrginfo(yr,m,imrg) = md0(yr,m,imrg);
display imrginfo;

a0(yr,imrg) = 0;
tax0(yr,imrg) = 0;
sbd0(yr,imrg) = 0;
x0(yr,imrg) = 0;
m0(yr,imrg) = 0;
md0(yr,m,imrg) = 0;
duty0(yr,imrg) = 0;

parameter	ta0(yr,i)	Tax net subsidy rate on intermediate demand,
		tm0(yr,i)	Import tariff;

tm0(yr,i)$duty0(yr,i) = duty0(yr,i)/m0(yr,i);
ta0(yr,i)$(tax0(yr,i)-sbd0(yr,i)) = (tax0(yr,i) - sbd0(yr,i))/a0(yr,i);

* -------------------------------------------------------------------
* 	Output non-calibrated parameters:
* -------------------------------------------------------------------

execute_unload 'temp\gdx\national_cgeparm_raw.gdx' y0,ys0,fs0,id0,fd0,va0,ts0,m0,x0,mrg0,trn0,duty0,sbd0,tax0,ms0,md0,s0,a0,bopdef,ta0,tm0,yr,i,va,fd,ts,m;