$title Map national sectors to non-numeric names

$if not set sectors	$set sectors eng
$if not set year 	$set year 2014

* -------------------------------------------------------------------
* 	Read in the dataset:
* -------------------------------------------------------------------

set	yr		Years of IO data,
	s		Goods\sectors (national data),
	m		Margins (trade or transport),
	fd		Final demand categories,
	va		Value added components;

$gdxin 'temp\gdx\national_cgeparm_bal_%sectors%.gdx'
$loaddc yr s=i va fd m
alias(s,g);

parameter	y0_(yr,s)	Gross output
		ys0_(yr,g,s)	Sectoral supply
		fs0_(yr,s)	Household supply
		id0_(yr,s,g)	Intermediate demand
		fd0_(yr,s,fd)	Final demand,
		va0_(yr,va,g)	Vaue added,
		m0_(yr,s)	Imports
		x0_(yr,s)	Exports of goods and services
		ms0_(yr,s,m)	Margin supply,
		md0_(yr,m,s)	Margin demand,
		s0_(yr,s)	Aggregate supply,
		a0_(yr,s)	Armington supply,
		bopdef0_(yr)	Balance of payments deficit,
		ta0_(yr,s)	Tax net subsidy rate on intermediate demand,
		tm0_(yr,s)	Import tariff;

$loaddc y0_=y_0 ys0_=ys_0 fs0_=fs_0 id0_=id_0 fd0_=fd_0 va0_=va_0 m0_=m_0 x0_=x_0
$loaddc ms0_=ms_0 md0_=md_0 s0_=s_0 a0_=a_0 bopdef0_=bopdef_0 ta0_=ta_0 tm0_=tm_0

set	i	Mapped goods and sector index listing /
$include "defines\goodssectors_names_%sectors%.set"
/,
	mapis(s,i)	Mapping between numeric and non-numeric sectors /
$include "defines\goodssectors_names_%sectors%.map"
/;

alias (i,j,ii,jj), (mapis,mapjg);

* -------------------------------------------------------------------
* 	Map national data to new set identifiers:
* -------------------------------------------------------------------

parameter	y_0(yr,i)	Gross output
		ys_0(yr,j,i)	Sectoral supply
		fs_0(yr,i)	Household supply
		id_0(yr,i,j)	Intermediate demand
		fd_0(yr,i,fd)	Final demand,
		va_0(yr,va,i)	Vaue added,
		m_0(yr,i)	Imports
		x_0(yr,i)	Exports of goods and services
		ms_0(yr,i,m)	Margin supply,
		md_0(yr,m,i)	Margin demand,
		s_0(yr,i)	Aggregate supply,
		a_0(yr,i)	Armington supply,
		ta_0(yr,i)	Tax net subsidy rate on intermediate demand,
		tm_0(yr,i)	Import tariff,
		bopdef_0(yr)	Balance of payments;

y_0(yr,i) = sum(mapis(s,i), y0_(yr,s));
ys_0(yr,j,i) = sum((mapis(s,i),mapjg(g,j)), ys0_(yr,g,s));
fs_0(yr,i) = sum(mapis(s,i), fs0_(yr,s));
id_0(yr,i,j) = sum((mapis(s,i),mapjg(g,j)), id0_(yr,s,g));
fd_0(yr,i,fd) = sum(mapis(s,i), fd0_(yr,s,fd));
va_0(yr,va,i) = sum(mapis(s,i), va0_(yr,va,s));
m_0(yr,i) = sum(mapis(s,i), m0_(yr,s));
x_0(yr,i) = sum(mapis(s,i), x0_(yr,s));
ms_0(yr,i,m) = sum(mapis(s,i), ms0_(yr,s,m));
md_0(yr,m,i) = sum(mapis(s,i), md0_(yr,m,s));
s_0(yr,i) = sum(mapis(s,i), s0_(yr,s));
a_0(yr,i) = sum(mapis(s,i), a0_(yr,s));
ta_0(yr,i) = sum(mapis(s,i), ta0_(yr,s));
tm_0(yr,i) = sum(mapis(s,i), tm0_(yr,s));
bopdef_0(yr) = bopdef0_(yr);

* -------------------------------------------------------------------
* Check microconsistency in a national accounting model:
* -------------------------------------------------------------------

$include 'nationalmodel.gms'
accounting.workspace = 100;
accounting.iterlim = 0;
$include 'temp\accounting.gen'
solve accounting using mcp;
abort$(accounting.objval>1e-5) "Error in benchmark calibration with national data.";

* -------------------------------------------------------------------
* Output mapped national dataset:
* -------------------------------------------------------------------

execute_unload 'temp\gdx\nationaldata_%sectors%.gdx' y_0,ys_0,fs_0,id_0,
    fd_0,va_0,m_0,x_0,ms_0,md_0,s_0,a_0,bopdef_0,ta_0,tm_0,yr,i,va,fd,m,s;