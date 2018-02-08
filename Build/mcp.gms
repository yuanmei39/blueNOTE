$title Micro-consistency check without subnational trade flows

$if not set year 	$set year 2014
$if not set sectors	$set sectors eng
$if not set calibto	$set calibto seds

* Stop program if reference case is sufficient:

$if %calibto% == no $exit

set	r	States,
	s	Goods\sectors (national data),
 	m	Margins (trade or transport),
	gm(s)	Commodities employed in margin supply;

$gdxin 'blueNOTE_%sectors%_%year%%calibto%.gdx'
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
$model:mge

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
	o:PA(r,g)	q:a0(r,g)		a:RA(r)	t:ta(r,g)	p:(1-ta0(r,g))
	o:PFX		q:rx0(r,g)
	i:PN(g)		q:nd0(r,g)	d:
	i:PD(r,g)	q:dd0(r,g)	d:
	i:PFX		q:m0(r,g)	dm: 	a:RA(r)	t:tm(r,g) 	p:(1+tm0(r,g))
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
$sysinclude mpsgeset mge

mge.workspace = 100;
mge.iterlim = 0;
$include mge.gen
solve mge using mcp;
abort$(mge.objval>1e-4) "Error in benchmark calibration with regional data.";

*	Define the corresponding MCP model 

equations
	profit_Y(r,s)		Zero profit: production
	profit_X(r,g)		Zero profit: disposition
	profit_A(r,g)		Zero profit: absorption
	profit_C(r)		Zero profit: final demand
	profit_MS(r,m)		Zero profit: margin supply

	market_PA(r,g)		Market clearance: absorption
	market_PY(r,g)		Market clearance: output
	market_PD(r,g)		Market clearance: local market
	market_PN(g)		Market clearance: national market
	market_PL(r)		Market clearance: labor
	market_PK(r,s)		Market clearance: capital
	market_PM(r,m)		Market clearance: margin
	market_PC(r)		Market clearance: consumption
	market_PFX		Market clearance: foreign exchange

	income_RA(r)		Income balance: representative agent;


parameter	alpha(r,s)	Labor value share;

alpha(r,s)$ld0(r,s) = ld0(r,s)/(ld0(r,s)+kd0(r,s));

$macro CVA(r,s)		(PL(r)**alpha(r,s)*PK(r,s)**(1-alpha(r,s)))
$macro AL(r,s)		(ld0(r,s)*cva(r,s)/PL(r))
$macro AK(r,s)		(kd0(r,s)*cva(r,s)/PK(r,s))

parameter	alphax(r,g)	Export value share
		alphad(r,g)	Local supply share
		alphan(r,g)	National supply share;

alphax(r,g)$(x0(r,g)-rx0(r,g)) = (x0(r,g)-rx0(r,g))/s0(r,g);
alphad(r,g)$xd0(r,g) = xd0(r,g)/s0(r,g);
alphan(r,g)$xn0(r,g) = xn0(r,g)/s0(r,g);

$macro RX(r,g)		((alphax(r,g)*PFX**5+alphan(r,g)*PN(g)**5+alphad(r,g)*PD(r,g)**5)**(1/5))
$macro AX(r,g)		((x0(r,g)-rx0(r,g))*(PFX/RX(r,g))**4)
$macro AN(r,g)		(xn0(r,g)*(PN(g)/RX(r,g))**4)
$macro AD(r,g)		(xd0(r,g)*(PD(r,g)/RX(r,g))**4)

parameter	thetan(r,g)	National share of domestic absorption
		thetam(r,g)	Domestic share of absorption;

thetan(r,g)$nd0(r,g) = nd0(r,g)/(nd0(r,g)+dd0(r,g));
thetam(r,g)$m0(r,g) = (1+tm0(r,g))*m0(r,g)/(nd0(r,g)+dd0(r,g)+m0(r,g)*(1+tm0(r,g)));

$macro CDN(r,g)		((thetan(r,g)*PN(g)**(1-2)+(1-thetan(r,g))*PD(r,g)**(1-2))**(1/(1-2)))
$macro CDM(r,g)		(((1-thetam(r,g))*CDN(r,g)**(1-4)+thetam(r,g)*(PFX*(1+tm(r,g))/(1+tm0(r,g)))**(1-4))**(1/(1-4)))

$macro DN(r,g)		(nd0(r,g)*(CDN(r,g)/PN(g))**2*(CDM(r,g)/CDN(r,g))**4)
$macro DD(r,g)		(dd0(r,g)*(CDN(r,g)/PD(r,g))**2*(CDM(r,g)/CDN(r,g))**4)
$macro MD(r,g)		(m0(r,g)*(CDM(r,g)*(1+tm0(r,g))/(PFX*(1+tm(r,g))))**4)

$macro CD(r,g)	(cd0(r,g)*PC(r)/PA(r,g))

profit_Y(y_(r,s))..		sum(g,PA(r,g)*id0(r,g,s)) + PL(r)*AL(r,s) + PK(r,s)*AK(r,s) =e= 

					sum(g, PY(r,g)*ys0(r,s,g));

profit_X(x_(r,g))..		PY(r,g)*s0(r,g) =e= PFX*AX(r,g) + PN(g)*AN(r,g) + PD(r,g)*AD(r,g);

profit_A(a_(r,g))..		PN(g)*DN(r,g) + PD(r,g)*DD(r,g) + PFX*(1+tm(r,g))*MD(r,g) + sum(m,PM(r,m)*md0(r,m,g)) =e= 

					PA(r,g)*(1-ta(r,g))*a0(r,g) + PFX*rx0(r,g);

profit_C(r)..			sum(g, PA(r,g)*CD(r,g)) =e= PC(r)*c0(r);

profit_MS(r,m)..		sum(gm, PN(gm)*nm0(r,m,gm) + PD(r,gm)*dm0(r,m,gm)) =e= PM(r,m)*sum(gm,md0(r,m,gm));

market_PA(pa_(r,g))..		A(r,g)*a0(r,g) =e= g0(r,g) + i0(r,g) + C(r)*CD(r,g) + sum(y_(r,s), Y(r,s)*id0(r,g,s));

market_PY(py_(r,g))..		sum(y_(r,s), Y(r,s)*ys0(r,s,g)) + yh0(r,g) =e= X(r,g)*s0(r,g);

market_PD(pd_(r,g))..		X(r,g)*AD(r,g) =e= A(r,g)*DD(r,g) + sum(m, MS(r,m)*dm0(r,m,g))$gm(g);

market_PN(g)..			sum(r,X(r,g)*AN(r,g)) =e= sum(r, A(r,g)*DN(r,g)) + sum((r,m), MS(r,m)*nm0(r,m,g))$gm(g);

market_PL(r)..			sum(s,ld0(r,s)) =e= sum(s, Y(r,s)*AL(r,s));

market_PK(pk_(r,s))..		kd0(r,s) =e= Y(r,s)*AK(r,s);

market_PM(r,m)..		MS(r,m)*sum(gm, md0(r,m,gm)) =e= sum(g, A(r,g)*md0(r,m,g));

market_PC(r)..			C(r)*c0(r) =e= RA(r)/PC(r);

market_PFX..			sum(r, bopdef0(r)) + sum((r,g),X(r,g)*AX(r,g)) + sum(a_(r,g), A(r,g)*rx0(r,g)) 
					
					=e= sum((r,g),A(r,g)*MD(r,g));

income_RA(r)..			RA(r) =e= sum(g,PY(r,g)*yh0(r,g)) + PFX*(bopdef0(r)+hhadj(r)) - sum(g, PA(r,g)*(g0(r,g)+i0(r,g)))
					
					+ PL(r)*sum(s,ld0(r,s)) + sum(pk_(r,s), PK(r,s)*kd0(r,s)) 
					
					+ sum(a_(r,g), A(r,g)*( MD(r,g)*PFX*tm(r,g) + a0(r,g)*PA(r,g)*ta(r,g) ));

model	mcp /
	profit_Y.Y, profit_X.X, profit_A.A, profit_C.C, profit_MS.MS,

	market_PA.PA, market_PY.PY, market_PD.PD, market_PN.PN,
	market_PL.PL, market_PK.PK, market_PM.PM, market_PC.PC,
	market_PFX.PFX,

	income_RA.RA /;

PK.FX(r,s)$(not kd0(r,s)) = 1;
PA.FX(r,g)$(not a0(r,g)) = 1;
PY.FX(r,g)$(not s0(r,g)) = 1;
PD.FX(r,g)$(not xd0(r,g)) = 1;

RA.L(r) = c0(r);

mcp.iterlim = 0;
solve mcp using mcp;
