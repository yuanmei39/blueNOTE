$title Micro-consistency check without subnational trade flows :/

$if not set year $set year 2014

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
		ta0(r,s)	Tax net subsidy rate on intermediate demand,
		tm0(r,s)	Import tariff,
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

ys0(r,g,s) = ys0_('%year%',r,g,s);
id0(r,s,g) = id0_('%year%',r,s,g);
ld0(r,s) = ld0_('%year%',r,s);
kd0(r,s) = kd0_('%year%',r,s);
m0(r,g) = m0_('%year%',r,g);
x0(r,g) = x0_('%year%',r,g);
rx0(r,g) = rx0_('%year%',r,g);
md0(r,m,gm) = md0_('%year%',r,m,gm);
nm0(r,m,gm) = nm0_('%year%',r,m,gm);
dm0(r,m,gm) = dm0_('%year%',r,m,gm);
s0(r,g) = s0_('%year%',r,g);
a0(r,g) = a0_('%year%',r,g);
ta0(r,g) = ta0_('%year%',r,g);
tm0(r,g) = tm0_('%year%',r,g);
cd0(r,g) = cd0_('%year%',r,g);
c0(r) = c0_('%year%',r);
yh0(r,g) = yh0_('%year%',r,g);
bopdef0(r) = bopdef0_('%year%',r);
g0(r,g) = g0_('%year%',r,g);
i0(r,g) = i0_('%year%',r,g);
xn0(r,g) = xn0_('%year%',r,g);
xd0(r,g) = xd0_('%year%',r,g);
dd0(r,g) = dd0_('%year%',r,g);
nd0(r,g) = nd0_('%year%',r,g);
hhadj(r) = hhadj_('%year%',r);

parameter	y_(r,s)		Sectors and regions with positive production,
		x_(r,g)		Disposition by region,
		a_(r,g)		Absorption by region;

y_(r,s)$(sum(g, ys0(r,s,g))>0) = 1;
x_(r,g)$s0(r,g) = 1;
a_(r,g)$(a0(r,g) + rx0(r,g)) = 1;

$ontext
$model:statemodel

$sectors:
	Y(r,s)$y_(r,s)		!	Production
	X(r,g)$x_(r,g)		!	Disposition
	A(r,g)$a_(r,g)		!	Absorption
	C(r)			!	Aggregate final demand
	MS(r,m)			!	Margin supply
	
$commodities:
	PA(r,g)$a0(r,g)		!	Regional market (input)
	PY(r,g)$s0(r,g)		!	Regional market (output)
	PD(r,g)$xd0(r,g)	!	Local market price
	PN(g)			!	National market
	PL(r)			!	Wage rate
	PK(r,s)$kd0(r,s)	!	Rental rate of capital
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

$prod:A(r,g)$a_(r,g)  s:0 dm:4  d(dm):2
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
$sysinclude mpsgeset statemodel

$call "copy statemodel.gen temp\statemodel.gen";
$call "del statemodel.gen";