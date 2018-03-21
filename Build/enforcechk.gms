$title Micro-consistency check without subnational trade flows

* Dataset directory structure:

$if not set dsdir 	$set dsdir datasets\

$if not set year 	$set year 2014
$if not set sectors	$set sectors eng
$if not set calibto	$set calibto seds

* Stop program if reference case is sufficient:

$if %calibto% == no $exit

set	r	States,
	s	Goods\sectors (national data),
 	m	Margins (trade or transport),
	gm(s)	Commodities employed in margin supply;

$gdxin '%dsdir%blueNOTE_%sectors%_%year%%calibto%.gdx'
$loaddc r s m
alias(s,g),(r,rr);

parameter	ys0(r,g,s)	Sectoral supply,
		id0(r,s,g)	Intermediate demand,
		ld0(r,s)	Labor demand,
		kd0(r,s)	Capital demand,
		m0(r,s)		Imports,
		x0(r,s)		Exports of goods and services,
		rx0(r,s)	Re-exports of goods and services,
		md0(r,m,s)	Total margin demand,
		nm0(r,m,g)	Margin demand from national market,
		dm0(r,m,g)	Margin supply from local market,
		s0(r,s)		Aggregate supply,
		a0(r,s)		Armington supply,
		ta0(r,s)	Benchmark excise tax
		ta(r,s)		Counterfactual excise tax
		tm0(r,s)	Benchmark import tariff,
		tm(r,s)		Counterfactual import tariff,
		cd0(r,s)	Final demand,
		c0(r)		Aggregate final demand,
		yh0(r,s)	Household production,
		bopdef0(r)	Balance of payments,
		hhadj(r)	Household adjustment,
		g0(r,s)		Government demand,
		i0(r,s)		Investment demand,
		xn0(r,g)	Regional supply to national market,
		xd0(r,g)	Regional supply to local market,
		dd0(r,g)	Regional demand from local  market,
		nd0(r,g)	Regional demand from national market;

* Production data: 

$loaddc ys0 ld0 kd0 id0

* Consumption data:

$loaddc yh0 cd0 c0 i0 g0 bopdef0 hhadj

* Trade data:

$loaddc s0 xd0 xn0 x0 rx0 a0 nd0 dd0 m0 ta0 tm0

ta(r,s) = ta0(r,s);
tm(r,s) = tm0(r,s);

* Margins:

$loaddc md0 nm0 dm0

gm(g) = yes$(sum((m,r), nm0(r,m,g) + dm0(r,m,g)) or sum((m,r), md0(r,m,g)));

sets	y_(r,s)		Production zero profit indicator,
	x_(r,g)		Disposition zero profit indicator,
	a_(r,g)		Absorption zero profit indicator,
	pa_(r,g)	Absorption market indicator,
	py_(r,g)	Output market indicator,
	pd_(r,g)	Regional market indicator,
	pk_(r,s)	Capital market indicator;

y_(r,s) = (sum(g, ys0(r,s,g))>0);
x_(r,g) = s0(r,g);
a_(r,g) = (a0(r,g) + rx0(r,g));
pa_(r,g) = a0(r,g);
py_(r,g) = s0(r,g);
pd_(r,g) = xd0(r,g);
pk_(r,s) = kd0(r,s);

$ontext
$model:enforcechk

$sectors:
	Y(r,s)$y_(r,s)		!	Production
	X(r,g)$x_(r,g)		!	Disposition
	A(r,g)$a_(r,g)		!	Absorption
	C(r)			!	Aggregate final demand
	MS(r,m)			!	Margin supply
	
$commodities:
	PA(r,g)$pa_(r,g)	!	Regional market (input)
	PY(r,g)$py_(r,g)	!	Regional market (output)
	PD(r,g)$pd_(r,g)	!	Local market price
	PN(g)			!	National market
	PL(r)			!	Wage rate
	PK(r,s)$pk_(r,s)	!	Rental rate of capital
	PM(r,m)			!	Margin price
	PC(r)			!	Consumer price index
	PFX			!	Foreign exchange

$consumer:
	RA(r)			!	Representative agent

$prod:Y(r,s)$y_(r,s)  s:0 va:1
	o:PY(r,g)	q:ys0(r,s,g)	
	i:PA(r,g)	q:id0(r,g,s)
	i:PL(r)		q:ld0(r,s)	va:
	i:PK(r,s)	q:kd0(r,s)	va:

$prod:X(r,g)$x_(r,g)  t:4
	o:PFX		q:(x0(r,g)-rx0(r,g))
	o:PN(g)		q:xn0(r,g)
	o:PD(r,g)	q:xd0(r,g)
	i:PY(r,g)	q:s0(r,g)

$prod:A(r,g)$a_(r,g)  s:0 dm:4  d:2
	o:PA(r,g)	q:a0(r,g)		a:RA(r)	t:ta0(r,g)	p:(1-ta0(r,g))
	o:PFX		q:rx0(r,g)
	i:PN(g)		q:nd0(r,g)	d:
	i:PD(r,g)	q:dd0(r,g)	d:
	i:PFX		q:m0(r,g)	dm: 	a:RA(r)	t:tm0(r,g) 	p:(1+tm0(r,g))
	i:PM(r,m)	q:md0(r,m,g)

$prod:MS(r,m)
	o:PM(r,m)	q:(sum(gm, md0(r,m,gm)))
	i:PN(gm)	q:nm0(r,m,gm)
	i:PD(r,gm)	q:dm0(r,m,gm)

$prod:C(r)  s:1
    	o:PC(r)		q:c0(r)
	i:PA(r,g)	q:cd0(r,g)
	
$demand:RA(r)
	d:PC(r)		q:c0(r)
	e:PY(r,g)	q:yh0(r,g)
	e:PFX		q:(bopdef0(r) + hhadj(r))
	e:PA(r,g)	q:(-g0(r,g) - i0(r,g))
	e:PL(r)		q:(sum(s,ld0(r,s)))
	e:PK(r,s)	q:kd0(r,s)

$offtext
$sysinclude mpsgeset enforcechk

$call "copy enforcechk.gen temp\enforcechk.gen";
$call "del enforcechk.gen";

enforcechk.workspace = 100;
enforcechk.iterlim = 0;
$include temp\enforcechk.gen
solve enforcechk using mcp;
abort$(enforcechk.objval>1e-4) "Error in benchmark calibration with regional data.";
