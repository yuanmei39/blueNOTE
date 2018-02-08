$title Include file for enforce.gms to calibrate to SEDS data

set	source 	Energy source
	sector 	Sector demanding energy source 
	type 	Units of the data;
	
parameter	rawseds(source,sector,type,r,yr)	SEDS energy data,
		sedsenergy(r,*,*,*,yr)			Reconciled SEDS energy data;

$gdxin '..\Data\SEDS\seds.gdx'
$loaddc source sector type
$loaddc rawseds sedsenergy

parameter	prodbtu(r,yr,*)		Total production of either natural gas or crude oil (trillions btu),
		prodval(r,yr,*)		Value of production using supply prices (billions dollars),
		ps0(yr,*)		Supply prices of crude oil and natural gas (dollars per million btu),
		sedsenergy(r,*,*,*,yr)	SEDS energy data;

parameter	crudeprice(*)		Crude Oil price (composite between domestic and international) in dollars per barrel,
		convfac(yr,r)		Conversion factor for translating dollars per barrel to dollars per million btu,
		cprice(yr,r)		Crude oil price in dollars per million btu;

$call 'gdxxrw.exe i=..\Data\SEDS\CrudeOil\crudeoil_dollarsperbarrel.xls o=temp\gdx\crude_price.gdx par=crudeprice rng=gams! rdim=1 cdim=0'
$gdxin 'temp\gdx\crude_price.gdx'
$loaddc crudeprice

convfac(yr,r) = rawseds('CO','PR','K',r,yr);
cprice(yr,r)$convfac(yr,r) = crudeprice(yr) / convfac(yr,r);

prodbtu(r,yr,'gas') = rawseds('NG','MP','B',r,yr) / 1000;
prodbtu(r,yr,'cru') = rawseds('PA','PR','B',r,yr) / 1000;

* Define energy prices:

set	e		Energy producing sectors in SEDS
			/ cru, gas, oil, ele, col /,
	demsec 		Demanding categories for energy
			/ ind	"Industry",
			  com	"Commercial",
			  res	"Residential",
			  trn	"Transportation",
			  ele	"Electricity generation",
			  ref	"Oil refining" /,
	fds_e(demsec)	Non energy final demand categories
			/ ind, com, res, trn /,
	mapdems(*,demsec) 	Mapping between SEDS and IO demanding sectors /
$include 'defines\mapdemsec.map'
/;

* Quick note on units. pe0 is in dollars per million btu's for non
* electricity energy sources. Prices are denominated in dollars per
* thousand kwhs for electricity. Multiplying price x quanitity below
* results in things denominated in millions of dollars. Scaling by 1000 ->
* billions of dollars per year.

parameter	pe0(yr,r,e,demsec)	Energy demand prices ($ per mbtu -- $ per thou kwh for ele),
		pele0(yr,*,demsec)	Electricity demand prices,
		pedef(yr,r,e)		Average energy demand prices;

pedef(yr,r,e)$sum(demsec, sedsenergy(r,"q",e,demsec,yr))
	 =	sum(demsec, sedsenergy(r,"p",e,demsec,yr)*sedsenergy(r,"q",e,demsec,yr)) /
		sum(demsec, sedsenergy(r,"q",e,demsec,yr));

* Otherwise, use the average across all regions which have a value:

pedef(yr,r,e)$(not pedef(yr,r,e) and sum(rr$pedef(yr,rr,e), sum(demsec, sedsenergy(rr,"q",e,demsec,yr)))) =	
	sum(rr, pedef(yr,rr,e)*sum(demsec, sedsenergy(rr,"q",e,demsec,yr))) /
	sum(rr$pedef(yr,rr,e), sum(demsec, sedsenergy(rr,"q",e,demsec,yr)));

pe0(yr,r,e,demsec) = pedef(yr,r,e);
pe0(yr,r,e,demsec)$sedsenergy(r,"p",e,demsec,yr) = sedsenergy(r,"p",e,demsec,yr);

* There is no price information for crude oil in SEDS. Use annual EIA
* averages:

pe0(yr,r,'cru',demsec) = cprice(yr,r);

* ps0 denotes the supply price of energy supply sources and is assumed to
* be the minimum price across regions. Note that industrial electricity
* Prices are quite a bit lower than other industries in each state.

ps0(yr,e)$(not sameas(e,'cru')) = smin((demsec,rr)$pe0(yr,rr,e,demsec),pe0(yr,rr,e,demsec));

* The demand for crude oil isn't differentiated on the basis of region and
* demanding sector. Assume it's supply price is half that of refined oil.

ps0(yr,'cru') = (ps0(yr,"oil")/2);

prodval(r,yr,'gas') = ps0(yr,'gas') * prodbtu(r,yr,'gas') / 1000;
prodval(r,yr,'cru') = ps0(yr,'cru') * prodbtu(r,yr,'cru') / 1000;

* Separate all parameters using the same share to maintain
* micro-consistency.

set	as	Additional sectors
		/ gas, cru /,
	mapog(as,s)	Mapping between oil and gas sectors
			/ gas.oil_oil, cru.oil_oil /,
	ds(*)	Disaggregate sectoring scheme;

parameter	shrgas(r,yr,as)	Share of production in each state for gas extraction;

shrgas(r,yr,as)$sum(as.local, prodval(r,yr,as)) = prodval(r,yr,as) / sum(as.local, prodval(r,yr,as));

* If no production data exists, use the average:

shrgas(r,yr,as)$(not shrgas(r,yr,as) and sum(g, ys0_(yr,r,'oil_oil',g))) = (1/sum(r.local$shrgas(r,yr,as), 1)) * sum(r.local, shrgas(r,yr,as));

parameter	ys0(yr,r,*,*)	Sectoral supply,
		id0(yr,r,*,*)	Intermediate demand,
		ld0(yr,r,*)	Labor demand,
		kd0(yr,r,*)	Capital demand,
		m0(yr,r,*)	Imports,
		x0(yr,r,*)	Exports of goods and services,
		rx0(yr,r,*)	Re-exports of goods and services,
		md0(yr,r,m,*)	Total margin demand,
		nm0(yr,r,m,*)	Margin demand from national market,
		dm0(yr,r,m,*)	Margin supply from local market,
		s0(yr,r,*)	Aggregate supply,
		a0(yr,r,*)	Armington supply,
		ta0(yr,r,*)	Tax net subsidy rate on intermediate demand,
		tm0(yr,r,*)	Import tariff,
		cd0(yr,r,*)	Final demand,
		c0(yr,r)	Aggregate final demand,
		yh0(yr,r,*)	Household production,
		fe0(yr,r)	Factor endowments,
		bopdef0(yr,r)	Balance of payments,
		hhadj(yr,r)	Household adjustment,
		g0(yr,r,*)	Government demand,
		i0(yr,r,*)	Investment demand,
		xn0(yr,r,*)	Regional supply to national market,
		xd0(yr,r,*)	Regional supply to local market,
		dd0(yr,r,*)	Regional demand from local  market,
		nd0(yr,r,*)	Regional demand from national market;

* Set values for unaffected parameters:

ld0(yr,r,s)$(not sameas(s,'oil_oil')) = ld0_(yr,r,s);
kd0(yr,r,s)$(not sameas(s,'oil_oil')) = kd0_(yr,r,s);
m0(yr,r,g)$(not sameas(g,'oil_oil')) = m0_(yr,r,g);
x0(yr,r,g)$(not sameas(g,'oil_oil')) = x0_(yr,r,g);
rx0(yr,r,g)$(not sameas(g,'oil_oil')) = rx0_(yr,r,g);
s0(yr,r,g)$(not sameas(g,'oil_oil')) = s0_(yr,r,g);
a0(yr,r,g)$(not sameas(g,'oil_oil')) = a0_(yr,r,g);
ta0(yr,r,g)$(not sameas(g,'oil_oil')) = ta0_(yr,r,g);
tm0(yr,r,g)$(not sameas(g,'oil_oil')) = tm0_(yr,r,g);
cd0(yr,r,g)$(not sameas(g,'oil_oil')) = cd0_(yr,r,g);
yh0(yr,r,g)$(not sameas(g,'oil_oil')) = yh0_(yr,r,g);
g0(yr,r,g)$(not sameas(g,'oil_oil')) = g0_(yr,r,g);
i0(yr,r,g)$(not sameas(g,'oil_oil')) = i0_(yr,r,g);
xn0(yr,r,g)$(not sameas(g,'oil_oil')) = xn0_(yr,r,g);
xd0(yr,r,g)$(not sameas(g,'oil_oil')) = xd0_(yr,r,g);
dd0(yr,r,g)$(not sameas(g,'oil_oil')) = dd0_(yr,r,g);
nd0(yr,r,g)$(not sameas(g,'oil_oil')) = nd0_(yr,r,g);
ys0(yr,r,s,g)$(not sameas(s,'oil_oil') and not sameas(g,'oil_oil')) = ys0_(yr,r,s,g);
id0(yr,r,g,s)$(not sameas(s,'oil_oil') and not sameas(g,'oil_oil')) = id0_(yr,r,g,s);
md0(yr,r,m,g)$(not sameas(g,'oil_oil')) = md0_(yr,r,m,g);
nm0(yr,r,m,g)$(not sameas(g,'oil_oil')) = nm0_(yr,r,m,g);
dm0(yr,r,m,g)$(not sameas(g,'oil_oil')) = dm0_(yr,r,m,g);    
c0(yr,r) = c0_(yr,r);
bopdef0(yr,r) = bopdef0_(yr,r);
hhadj(yr,r) = hhadj_(yr,r);
    
* Share out oil and gas extraction sector:

ld0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * ld0_(yr,r,s));
kd0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * kd0_(yr,r,s));
m0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * m0_(yr,r,s));
x0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * x0_(yr,r,s));
rx0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * rx0_(yr,r,s));
s0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * s0_(yr,r,s));
a0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * a0_(yr,r,s));
ta0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * ta0_(yr,r,s));
tm0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * tm0_(yr,r,s));
cd0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * cd0_(yr,r,s));
yh0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * yh0_(yr,r,s));
g0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * g0_(yr,r,s));
i0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * i0_(yr,r,s));
xn0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * xn0_(yr,r,s));
xd0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * xd0_(yr,r,s));
dd0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * dd0_(yr,r,s));
nd0(yr,r,as) = sum(mapog(as,s), shrgas(r,yr,as) * nd0_(yr,r,s));
md0(yr,r,m,as) = sum(mapog(as,s), shrgas(r,yr,as) * md0_(yr,r,m,s));
nm0(yr,r,m,as) = sum(mapog(as,s), shrgas(r,yr,as) * nm0_(yr,r,m,s));
dm0(yr,r,m,as) = sum(mapog(as,s), shrgas(r,yr,as) * dm0_(yr,r,m,s));

alias(as,as_);

ys0(yr,r,s,as)$(not sameas(s,'oil_oil')) = sum(mapog(as,g), shrgas(r,yr,as) * ys0_(yr,r,s,g));
ys0(yr,r,as,g)$(not sameas(g,'oil_oil')) = sum(mapog(as,s), shrgas(r,yr,as) * ys0_(yr,r,s,g));

* Assume there is no byproduct production between both crude oil and
* natural gas.

ys0(yr,r,as,as) = sum(mapog(as,s), shrgas(r,yr,as) * ys0_(yr,r,s,s));

id0(yr,r,g,as)$(not sameas(g,'oil_oil')) = sum(mapog(as,s), shrgas(r,yr,as) * id0_(yr,r,g,s));
id0(yr,r,as,s)$(not sameas(s,'oil_oil')) = sum(mapog(as,g), shrgas(r,yr,as) * id0_(yr,r,g,s));
id0(yr,r,as,as) = sum(mapog(as,s), shrgas(r,yr,as) * id0_(yr,r,s,s));

ds(s)$(not sameas(s,'oil_oil')) = yes;
ds(as) = yes;
alias(ds,dg);

* -------------------------------------------------------------------------
* Enforce that supply sent to other regions in the county or imported from
* other states line up with net generation. Also, enforce aggregate
* production value of electricity is in line with seds for 
* -------------------------------------------------------------------------

parameter	netgen(r,yr,*)	Net interstate flows of electricity (10s of bill $),
		trdele(r,yr,*)	Electricity imports-exports to-from USA (10s of bill. $),
		elesup(r,yr)	Impose electricity supply totals based on SEDS,
		eledem(r,yr)	Energy demand based on SEDS;

netgen(r,yr,'seds') = ps0(yr,'ele')/1000 * rawseds('EL','IS','P',r,yr)/1000;
netgen(r,yr,'seds') = netgen(r,yr,'seds')/10;
netgen(r,yr,'io') = nd0(yr,r,'ele_uti') - xn0(yr,r,'ele_uti');

* Initial data is in millions of dollars:

trdele(r,yr,'imp') = rawseds('EL','IM','V',r,yr)/10000;
trdele(r,yr,'exp') = rawseds('EL','EX','V',r,yr)/10000;

x0(yr,r,'ele_uti') = trdele(r,yr,'exp');
m0(yr,r,'ele_uti') = trdele(r,yr,'imp');

* Now fix demand and supply, attributing the difference to retail margins.

table hrate(yr,*)
	col	oil	gas	nu
2005	10373	10631	8551	10436
2006	10351	10809	8471	10435
2007	10375	10794	8403	10489
2008	10378	11015	8305	10452
2009	10414	10923	8160	10459
2010	10415	10984	8185	10452
2011	10444	10829	8152	10464
2012	10498	10991	8039	10479
2013	10459	10713	7948	10449
2014	10428	10814	7907	10459
2015	10495	10687	7878	10458 
;

alias(*,u);
parameter	htrate(yr,*) Average heat rates (btu per kwh);

htrate(yr,u) = hrate(yr,u);

* For years not listed use earliest recoreded year:

htrate(yr,u)$(not htrate(yr,u)) = htrate('2005',u);

set	src 	Energy Technologies
		/ col	'Coal',
		  gas	'Natural gas',
		  oil	'Crude oil',
		  nu	'Nuclear',
		  hy	'Hydro power',
		  ge	'Geothermal',
		  so	'Solar power',
		  wy	'Wind energy ' /;

parameter	elegen	Electricity generation by source (mill. btu or tkwh for ele);

loop(r,

* Initial data is in billions of btu. Scaling by htrate converts to billions of kwh.

	elegen(r,"col",yr) = rawseds("cl","ei","b",r,yr)/htrate(yr,"col");
	elegen(r,"gas",yr) = rawseds("ng","ei","b",r,yr)/htrate(yr,"gas");
	elegen(r,"oil",yr) = rawseds("pa","ei","b",r,yr)/htrate(yr,"oil");

* Initial data is in millions of kwh. Scaling by 1000 converts to billions of kwh.

	elegen(r,"nu",yr) = rawseds("nu","eg","p",r,yr)/1000;
	elegen(r,"hy",yr) = rawseds("hy","eg","p",r,yr)/1000;
	elegen(r,"ge",yr) = rawseds("ge","eg","p",r,yr)/1000;
	elegen(r,"so",yr) = rawseds("so","eg","p",r,yr)/1000;
	elegen(r,"wy",yr) = rawseds("wy","eg","p",r,yr)/1000;
);

elegen("total",src,yr) = sum(r,elegen(r,src,yr));
elegen(r,"total",yr) = sum(src,elegen(r,src,yr));
elegen("total","total",yr) = sum(src,elegen("total",src,yr));

* Electricity demand should be shared across sectors in each
* category. Margin demand will be defined as the difference between the
* two.

parameter	eq0(yr,r,*,*)		Energy demand (btu or mwh),
		pe0(yr,r,e,demsec)	Demand energy prices,
		ed0(yr,r,e,demsec)	Energy demand (10s of bill $ value gross margin),
		emarg0(yr,r,e,*)	Margin demand for energy markups (10s of bill $),
		ned0(yr,r,*,*)		Net energy demands (10s of bill $ value net of margin);


eq0(yr,r,e,demsec) = max(0,sedsenergy(r,"q",e,demsec,yr));
ed0(yr,r,e,demsec) = (pe0(yr,r,e,demsec)  * eq0(yr,r,e,demsec)/1000) / 10;
emarg0(yr,r,e,demsec)$ed0(yr,r,e,demsec) = ((pe0(yr,r,e,demsec)-ps0(yr,e)) * eq0(yr,r,e,demsec)/1000) / 10;
ned0(yr,r,e,demsec) = (ed0(yr,r,e,demsec) - emarg0(yr,r,e,demsec)) / 10;

* Assume margins for energy is aggregated and applied uniformily to all
* demanding sectors for each energy type. I.e. adjust md0(yr,r,e) for
* margins and id0(r,e,demsec) and cd0(r,e) for demands.

set	ioe(*)	Energy sectors in the IO data
		/ col_min, cru, gas, ref_pet, ele_uti /,
	mapioe(ioe,e)
		/ col_min.col, cru.cru, gas.gas, ref_pet.oil, ele_uti.ele /;

* Resource related energy goods already had margins in the data. Share out
* new totals using existing margins.

parameter	margshr(yr,r,m,*);

margshr(yr,r,'trn',ioe)$sum(m, md0(yr,r,m,ioe)) = md0(yr,r,'trn',ioe) / sum(m, md0(yr,r,m,ioe));
margshr(yr,r,'trd',ioe) = 1 - margshr(yr,r,'trn',ioe);

md0(yr,r,m,'col_min') = margshr(yr,r,m,'col_min') * sum(demsec, emarg0(yr,r,'col',demsec));
md0(yr,r,m,'cru') = margshr(yr,r,m,'cru') * sum(demsec, emarg0(yr,r,'cru',demsec));
md0(yr,r,m,'gas') = margshr(yr,r,m,'gas') * sum(demsec, emarg0(yr,r,'gas',demsec));
md0(yr,r,m,'ref_pet') = margshr(yr,r,m,'ref_pet') * sum(demsec, emarg0(yr,r,'oil',demsec));
md0(yr,r,m,'ele_uti') = margshr(yr,r,m,'ele_uti') * sum(demsec, emarg0(yr,r,'ele',demsec));

* Compare new and old energy input demands:

parameter	enegdem(yr,r,ioe,*);

enegdem(yr,r,ioe,'old') = sum(dg, id0(yr,r,ioe,dg)) + cd0(yr,r,ioe);

* Check on residential energy demands. Electricity demands line up quite
* well.

parameter	resechk		Residential energy demand check;

resechk(yr,r,ioe,'old') = cd0(yr,r,ioe);
cd0(yr,r,ioe) = sum(mapioe(ioe,e), ed0(yr,r,e,'res'));
resechk(yr,r,ioe,'new') = cd0(yr,r,ioe);

* Share out input demands for production:

parameter	inpshrs(yr,r,*,demsec,*)	Shares of input demand by sector,
		inpchk(yr,r,*,*)		Check on energy input demand;

inpshrs(yr,r,ioe,demsec,ds)$(sum(ds.local$mapdems(ds,demsec), id0(yr,r,ioe,ds)) and mapdems(ds,demsec)) = 
		id0(yr,r,ioe,ds) / sum(ds.local$mapdems(ds,demsec), id0(yr,r,ioe,ds));

inpchk(yr,r,ds,'old') = sum(ioe, id0(yr,r,ioe,ds));
id0(yr,r,ioe,ds) = sum(demsec, inpshrs(yr,r,ioe,demsec,ds) * sum(mapioe(ioe,e), ed0(yr,r,e,demsec)));
inpchk(yr,r,ds,'new') = sum(ioe, id0(yr,r,ioe,ds));

* Finally, adjust supply totals:

parameter	compele	Comparison of net and gross electricity production;

compele(yr,r,'old') = ys0(yr,r,'ele_uti','ele_uti');
compele(yr,r,'new') = elegen(r,'total',yr) * ps0(yr,'ele')/1000;

ys0(yr,r,'ele_uti','ele_uti') =  elegen(r,'total',yr) * ps0(yr,'ele')/1000;
ys0(yr,r,"cru",'cru') = sedsenergy(r,"q","cru","supply",yr)*ps0(yr,'cru')/1000;
ys0(yr,r,"gas",'gas') = sedsenergy(r,"q","gas","supply",yr)*ps0(yr,"gas")/1000;
ys0(yr,r,"col_min",'col_min') = sedsenergy(r,"q","col","supply",yr)*ps0(yr,"col")/1000;
ys0(yr,r,"ref_pet",'ref_pet') = sedsenergy(r,"q","cru","ref",yr)/sum(r.local,sedsenergy(r,"q","cru","ref",yr)) * 
	sum((demsec,r.local),ned0(yr,r,"oil",demsec));

enegdem(yr,r,ioe,'new') = sum(dg, id0(yr,r,ioe,dg)) + cd0(yr,r,ioe);
display enegdem;
