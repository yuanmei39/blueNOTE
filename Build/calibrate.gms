$title	Balance the dataset and verify benchmark consistency

* -------------------------------------------------------------------
* 	Set optimization routine for matrix balancing:
*	Least Squares (ls) or Huber (huber)

*	Note that the routine computes the solution for both methods and
*	reports the percent difference between the two. The set
*	environment variable is the chosen of the two methods.

* -------------------------------------------------------------------

$if not set matbal $set matbal huber

set	bal	Matrix balancing objectives / ls, huber /;

* Set year for calibration check using an accounting model:

$if not set year $set year 2014

* Set sector disagregation:

$if not set sectors $set sectors eng

* -------------------------------------------------------------------
* 	Read in the dataset:
* -------------------------------------------------------------------

set	yr	Years of IO data,
	i	Goods\sectors,
	m	Margins (trade or transport),
	fd	Final demand categories,
	va	Value added components,
	ts	Taxes or subsidies /
$include 'defines\taxessubsidies.set'
/;

$gdxin 'temp\gdx\sectordisagg.gdx'
$loaddc yr i=gi va=va_nm fd=fd_nm m
alias(i,j);

parameter	y_0(yr,i)	Gross output
		ys_0(yr,j,i)	Sectoral supply
		fs_0(yr,i)	Household supply
		id_0(yr,i,j)	Intermediate demand
		fd_0(yr,i,fd)	Final demand,
		va_0(yr,va,j)	Vaue added,
		ts_0(yr,ts,i)	Taxes and subsidies
		m_0(yr,i)	Imports
		x_0(yr,i)	Exports of goods and services
		mrg_0(yr,i)	Trade margins
		trn_0(yr,i)	Transportation costs
		duty_0(yr,i)	Import duties
		sbd_0(yr,i)	Subsidies on products,
		tax_0(yr,i)	Taxes on products,
		ms_0(yr,i,m)	Margin supply,
		md_0(yr,m,i)	Margin demand,
		s_0(yr,i)	Aggregate supply,
		d_0(yr,i)	Sales in the domestic market,
		a_0(yr,i)	Armington supply,
		bopdef_0(yr)	Balance of payments deficit,
		ta_0(yr,i)	Tax net subsidy rate on intermediate demand,
		tm_0(yr,i)	Import tariff;

$loaddc y_0=y0_yr ys_0=ys0_yr fs_0=fs0_yr id_0=id0_yr fd_0=fd0_yr va_0=va0_yr m_0=m0_yr 
$loaddc x_0=x0_yr ms_0=ms0_yr md_0=md0_yr a_0=a0_yr ta_0=ta0_yr tm_0=tm0_yr

* -------------------------------------------------------------------
* 	Matrix balancing routine (LS, Huber):
* -------------------------------------------------------------------

$ontext
Huber's approach to matrix balancing incorporates a barrier function
to assure that nonzeros in the source data remain nonzero in the
estimated matrix.

Huber's loss function is represented by:

                | a0 * sqr(a/a0 - 1)            for |a/a0-1| <= theta
        L(a) =  |
                | a0 * 2 * theta * |a/a0-1|     for |a/a0-1| >= theta

The loss function is quadratic in the neighborhood of a0 and becomes
linear as we move away from the target, with a slope chosen to
maintain continuity of the first derivative across the threshold value
a=a0*(1+theta) ).

The motivation for Huber's approach is to overcome the disadvantage of
the least squares approach to "outliers" -- residuals which are large
in magnitude.  These are squared in the conventional least-squares
formulation and therefore contribute heavily to the objective
function.  Outliers in the least-squares model have an undue influence
over the recalibration point.  Huber's approach places less weight on
the outlying points and 

See http://en.wikipedia.org/wiki/Robust_statistics or Huber (1981)
(Robust Statistics, John Wiley and Sons, New York).

In the hybrid barrier method we retain Huber's loss function for
increases from the target value and we add a log term to penalize
values which go to zero:

        | a0 * 2 * theta * (a/a0-1)			for a/a0-1 >= theta
        |
L(a) =  | a0 * sqr(a/a0 - 1)				for -gamma <= a/a0-1 <= theta
        |
        | a0 * 2 * gamma * (1-gamma) * log(a/a0)	for a/a0-1 <= -gamma

$offtext

* Define parameter structure without time index:

parameter	y0(i)		Gross output
		ys0(j,i)	Sectoral supply
		fs0(i)		Household supply
		id0(i,j)	Intermediate demand
		fd0(i,fd)	Final demand,
		va0(va,j)	Vaue added,
		ts0(ts,i)	Taxes and subsidies
		m0(i)		Imports
		x0(i)		Exports of goods and services
		mrg0(i)		Trade margins
		trn0(i)		Transportation costs
		duty0(i)	Import duties
		sbd0(i)		Subsidies on products,
		tax0(i)		Taxes on products,
		ms0(i,m)	Margin supply,
		md0(m,i)	Margin demand,
		s0(i)		Aggregate supply,
		d0(i)		Sales in the domestic market,
		a0(i)		Armington supply,
		bopdef		Balance of payments deficit,
		ta0(i)		Tax net subsidy rate on intermediate demand,
		tm0(i)		Import tariff;

* Additional parameters needed if using Huber's matrix balancing routine:

sets	mat 	Select parameters for huber objective /ys0,id0/;

set	nonzero(mat,i,j)	Nonzeros in the reference data,
	zeros(mat,i,j)		Zeros in the reference data;

parameter	v0(mat,i,j)	matrix values;

parameter       gammab   Lower bound cross-over tolerance /0.5/,
		thetab   Upper bound cross-over tolerance /0.25/;

nonnegative
variables	ys0_(j,i), fs0_(i), ms0_(i,m), y0_(i)	Calibration variables,
		id0_(i,j), fd0_(i,fd), va0_(va,j)	Calibration variables, 
		a0_(i), x0_(i), m0_(i), md0_(m,i)	Calibration variables,
		X1(mat,i,j)				Percentage deviations,
		X2(mat,i,j)				Percentage deviations, 
		X3(mat,i,j)				Percentage deviations;

variables	OBJ;

equations	lsobj, huberobj, mkt_py, mkt_pa, mkt_pm, prf_y, prf_a, x2def, x3def;

* -------------------------------------------------------------------
* 	Least squares objective function:
* -------------------------------------------------------------------

lsobj..	OBJ =e= 	sum((j,i),  ys0(j,i) * sqr(ys0_(j,i)-ys0(j,i))) +
			sum((i,j),  id0(i,j) * sqr(id0_(i,j)-id0(i,j))) +

			sum((i),    fs0(i) * sqr(fs0_(i)-fs0(i))) +
			sum((i,m),  ms0(i,m) * sqr(ms0_(i,m)-ms0(i,m))) +
			sum((i),    y0(i) * sqr(y0_(i)-y0(i))) +
			sum((i,fd), fd0(i,fd) * sqr(fd0_(i,fd)-fd0(i,fd))) +
			sum((va,j), va0(va,j) * sqr(va0_(va,j)-va0(va,j))) + 
			sum((i),    a0(i) * sqr(a0_(i)-a0(i))) +
			sum((i),    x0(i) * sqr(x0_(i)-x0(i))) +
			sum((i),    m0(i) * sqr(m0_(i)-m0(i))) +
			sum((m,i),  md0(m,i) * sqr(md0_(m,i)-md0(m,i))) +

			1e6 * (
			sum((j,i)$(not ys0(j,i)), ys0_(j,i)) +
			sum((i)$(not fs0(i)), fs0_(i)) +
			sum((i,m)$(not ms0(i,m)), ms0_(i,m)) +
			sum((i)$(not y0(i)), y0_(i)) +
			sum((i,j)$(not id0(i,j)), id0_(i,j)) +
			sum((i,fd)$(not fd0(i,fd)), fd0_(i,fd)) +
			sum((va,j)$(not va0(va,j)), va0_(va,j)) +
			sum((i)$(not a0(i)), a0_(i)) +
			sum((i)$(not x0(i)), x0_(i)) +
			sum((i)$(not m0(i)), m0_(i)) +
			sum((m,i)$(not md0(m,i)), md0_(m,i)));

* -------------------------------------------------------------------
* 	Huber objective function (with additional constraints):
* -------------------------------------------------------------------

$macro	MV(mat,i,j) (ys0_(i,j)$sameas(mat,"ys0") + id0_(i,j)$sameas(mat,"id0"))

x2def(nonzero(mat,i,j))..   X2(mat,i,j) + X1(mat,i,j) =g= (MV(mat,i,j)/v0(mat,i,j)-1);

x3def(nonzero(mat,i,j))..   X3(mat,i,j) - X2(mat,i,j) =g= (1-MV(mat,i,j)/v0(mat,i,j));

huberobj..  OBJ =e= 	sum(nonzero(mat,i,j), abs(v0(mat,i,j)) * 
	                (sqr(X2(mat,i,j)) + 2*thetab*X1(mat,i,j) - 
			2*gammab*(1-gammab)*log(1-gammab-X3(mat,i,j)))) +

			sum((i),    fs0(i) * sqr(fs0_(i)-fs0(i))) +
			sum((i,m),  ms0(i,m) * sqr(ms0_(i,m)-ms0(i,m))) +
			sum((i),    y0(i) * sqr(y0_(i)-y0(i))) +
			sum((i,fd), fd0(i,fd) * sqr(fd0_(i,fd)-fd0(i,fd))) +
			sum((va,j), va0(va,j) * sqr(va0_(va,j)-va0(va,j))) + 
			sum((i),    a0(i) * sqr(a0_(i)-a0(i))) +
			sum((i),    x0(i) * sqr(x0_(i)-x0(i))) +
			sum((i),    m0(i) * sqr(m0_(i)-m0(i))) +
			sum((m,i),  md0(m,i) * sqr(md0_(m,i)-md0(m,i))) +

			1e6 * (
			sum((j,i)$(not ys0(j,i)), ys0_(j,i)) +
			sum((i)$(not fs0(i)), fs0_(i)) +
			sum((i,m)$(not ms0(i,m)), ms0_(i,m)) +
			sum((i)$(not y0(i)), y0_(i)) +
			sum((i,j)$(not id0(i,j)), id0_(i,j)) +
			sum((i,fd)$(not fd0(i,fd)), fd0_(i,fd)) +
			sum((va,j)$(not va0(va,j)), va0_(va,j)) +
			sum((i)$(not a0(i)), a0_(i)) +
			sum((i)$(not x0(i)), x0_(i)) +
			sum((i)$(not m0(i)), m0_(i)) +
			sum((m,i)$(not md0(m,i)), md0_(m,i)));

* Set accounting constraints for the data:

mkt_py(i)..	sum(j, ys0_(j,i)) +  fs0_(i) =e= sum(m, ms0_(i,m)) + y0_(i);

mkt_pa(i)..	a0_(i) =e= sum(j, id0_(i,j)) + sum(fd,fd0_(i,fd));

mkt_pm(m)..	sum(i,ms0_(i,m)) =e= sum(i, md0_(m,i));

prf_y(j)..	sum(i, ys0_(j,i)) =e= sum(i, id0_(i,j)) + sum(va,va0_(va,j));

prf_a(i)..	a0_(i)*(1-ta0(i)) + x0_(i) =e= y0_(i) + m0_(i)*(1+tm0(i)) + sum(m, md0_(m,i));

model balance_ls / lsobj, mkt_py, mkt_pa, mkt_pm, prf_y, prf_a /;
model balance_huber / huberobj, mkt_py, mkt_pa, mkt_pm, prf_y, prf_a, x2def, x3def /;

* Set negative numbers to zero:

ys_0(yr,j,i) = max(0, ys_0(yr,j,i));
id_0(yr,i,j) = max(0, id_0(yr,i,j));
va_0(yr,va,j) = max(0, va_0(yr,va,j));
a_0(yr,i) = max(0, a_0(yr,i));
x_0(yr,i) = max(0, x_0(yr,i));
y_0(yr,i) = max(0, y_0(yr,i));
m_0(yr,i) = max(0, m_0(yr,i));
duty_0(yr,i)$(not m_0(yr,i)) = 0;
md_0(yr,m,i) = max(0,md_0(yr,m,i));
fd_0(yr,i,"pce") = max(0, fd_0(yr,i,"pce"));
ms_0(yr,i,m) = max(0, ms_0(yr,i,m));

* Write a report on which years solve optimally and create solutions
* parameter:

parameter	report		Solve report for yearly IO recalibration,
		solution	Solutions to matrix balancing problem,
		bench		Reference benchmark parameters;

bench('ys0',yr,j,i) = ys_0(yr,j,i);
bench('fs0',yr,i,' ') = fs_0(yr,i);
bench('ms0',yr,i,m) = ms_0(yr,i,m);
bench('y0',yr,i,' ') = y_0(yr,i);
bench('id0',yr,i,j) = id_0(yr,i,j);
bench('fd0',yr,i,fd) = fd_0(yr,i,fd);
bench('va0',yr,va,j) = va_0(yr,va,j);
bench('a0',yr,i,' ') = a_0(yr,i);
bench('x0',yr,i,' ') = x_0(yr,i);
bench('m0',yr,i,' ') = m_0(yr,i);
bench('md0',yr,m,i) = md_0(yr,m,i);

alias(u,uu,uuu,*);

* Run a loadpoint script to save reference solutions for easier future
* computations. Note that in order to circumvent compilation vs. execution
* timing issues, I generate wrappers using $onecho and $offecho.

$if not exist "temp\loadpoint" $call 'mkdir temp\loadpoint'

$onecho > 'temp\loadpoint\sets.gms'
set	yr	Years of IO data,
	i	Goods\sectors,
	m	Margins (trade or transport),
	fd	Final demand categories,
	va	Value added components,
	ts	Taxes or subsidies,
	bal	Matrix balancing objectives / ls, huber /;

$gdxin 'temp\gdx\national_cgeparm_raw.gdx'
$loaddc yr i va fd ts m
alias(i,j);
$offecho

$onecho > 'temp\loadpoint\loaddir.gms'
$include 'temp\loadpoint\sets.gms'
file loadpntdir /temp\loadpoint\loadpntdir.gms/;
put loadpntdir '* Create a directory structure for loadpoint gdx files.';
loop(yr,
	put	/"execute 'mkdir temp\loadpoint\" yr.tl:0"';"
);
$offecho

$call 'gams temp\loadpoint\loaddir.gms o=temp\lst\loaddir.lst'
$call 'gams temp\loadpoint\loadpntdir.gms o=temp\lst\loadpntdir.lst'

$onecho > 'temp\loadpoint\loadproc.gms'
$include 'temp\loadpoint\sets.gms'
file loadpntcopy /temp\loadpoint\loadpntcopy.gms/;
put loadpntcopy '* Create GAMS include file for copying loadpoint GDX files.';
loop((yr,bal),
*	put	/"if ((sameas(yr,'" yr.tl:0 "') and sameas(bal,'" bal.tl:0 "')), execute 'xcopy balance_" bal.tl:0 "_p.gdx temp\loadpoint\" yr.tl:0 "\balance_" bal.tl:0 "_p_%sectors%.gdx /Y'; );"
    	put	/"if ((sameas(yr,'" yr.tl:0 "') and sameas(bal,'" bal.tl:0 "')), execute 'copy balance_" bal.tl:0 "_p.gdx temp\loadpoint\" yr.tl:0 "\balance_" bal.tl:0 "_p_%sectors%.gdx'; );"
);

file loadpntinc /temp\loadpoint\loadpntinc.gms/;
put loadpntinc '* Create GAMS include file for multiple loadpoint GDX files.';
loop((yr,bal),
	put	/"$if exist 'temp\loadpoint\" yr.tl:0 "\balance_" bal.tl:0 "_p_%sectors%.gdx'"
	put	/"if ((sameas(yr,'" yr.tl:0 "') and sameas(bal,'" bal.tl:0 "')), execute_loadpoint 'temp\loadpoint\" yr.tl:0 "\balance_" bal.tl:0 "_p_%sectors%.gdx'; );"
	put	/
);
$offecho

$call 'gams temp\loadpoint\loadproc.gms o=temp\lst\loadproc.lst'

* -------------------------------------------------------------------
* 	Loop over years and matrix balancing techniques to solve:
* -------------------------------------------------------------------

loop(bal,
loop(yr,

* Set parameter values:

y0(i) = y_0(yr,i);
ys0(j,i) = ys_0(yr,j,i);
fs0(i) = fs_0(yr,i);
id0(i,j) = id_0(yr,i,j);
fd0(i,fd) = fd_0(yr,i,fd);
va0(va,j) = va_0(yr,va,j);
m0(i) = m_0(yr,i);
x0(i) = x_0(yr,i);
ms0(i,m) = ms_0(yr,i,m);
md0(m,i) = md_0(yr,m,i);
a0(i) = a_0(yr,i);
ta0(i) = ta_0(yr,i);
tm0(i) = tm_0(yr,i);

* Lower bounds on re-calibrated parameters set to 10% of listed value:

ys0_.LO(j,i) = max(0,0.1 * ys0(j,i));
ms0_.LO(i,m) = max(0,0.1 * ms0(i,m));
y0_.LO(i) = max(0,0.1 * y0(i));
id0_.LO(i,j) = max(0,0.1 * id0(i,j));
fd0_.LO(i,fd) = max(0,0.1 * fd0(i,fd));
a0_.LO(i) = max(0,0.1 * a0(i));
x0_.LO(i) = max(0,0.1 * x0(i));
m0_.LO(i) = max(0,0.1 * m0(i));
md0_.LO(m,i) = max(0,0.1 * md0(m,i));
va0_.LO(va,j) = max(0,0.1 * va0(va,j));

* Upper bounds on re-calibrated parameters set to 5x listed value:

ys0_.UP(j,i)$ys0(j,i)  = abs(5 * ys0(j,i));
id0_.UP(i,j)$id0(i,j)  = abs(5 * id0(i,j));
ms0_.UP(i,m)$ms0(i,m)  = abs(5 * ms0(i,m));
y0_.UP(i)$y0(i)  = abs(5 * y0(i));
fd0_.UP(i,fd)$fd0(i,fd)  = abs(5 * fd0(i,fd));
va0_.UP(va,j)$va0(va,j)  = abs(5 * va0(va,j));
a0_.UP(i)$a0(i)  = abs(5 * a0(i));
x0_.UP(i)$x0(i)  = abs(5 * x0(i));
m0_.UP(i)$m0(i)  = abs(5 * m0(i));
md0_.UP(m,i)$md0(m,i)  = abs(5 * md0(m,i));

* Fix certain parameters -- exogenous portions of final demand, value
* added, imports and household supply.

*fd0_.FX(i,fd)$(not sameas(fd,"pce")) = fd0(i,fd);
fs0_.FX(i) = fs0(i);
va0_.FX(va,j) = va0(va,j);
m0_.fx(i) = m0(i);

* Additional parameters for using Huber's objective function:

if (sameas(bal,"huber"),
v0("ys0",i,j) = ys_0(yr,i,j);
v0("id0",i,j) = id_0(yr,i,j);
nonzero(mat,i,j) = yes$v0(mat,i,j);
zeros(mat,i,j) = yes$(not v0(mat,i,j));
X1.FX(zeros) = 0;
X2.FX(zeros) = 0;
X3.FX(zeros) = 0;
X2.UP(nonzero) = thetab;
X2.LO(nonzero) = -gammab;
X3.UP(nonzero) = 1-gammab-1e-5;
X3.LO(nonzero) = 0;
X1.L(nonzero) = 0;
X2.L(nonzero) = 0;
X3.L(nonzero) = 0;);

* Include loadpoint text files to save reference solutions for easier
* future computations:

if (sameas(bal,"huber"),
balance_huber.holdfixed = 1;
balance_huber.savepoint = 1;);

if (sameas(bal,"ls"),
balance_ls.holdfixed = 1;
balance_ls.savepoint = 1;);

$include 'temp/loadpoint/loadpntinc.gms'

if (sameas(bal,"huber"), solve balance_huber using NLP minimizing OBJ;);
if (sameas(bal,"ls"), solve balance_ls using NLP minimizing OBJ;);

$include 'temp/loadpoint/loadpntcopy.gms'

if (sameas(bal,"huber"), report(yr,'modelstat','huber') = balance_huber.modelstat;);
if (sameas(bal,"ls"), report(yr,'modelstat','ls') = balance_ls.modelstat;);

* Save the solution:

solution(bal,'ys0',yr,j,i) = ys0_.L(j,i);
solution(bal,'fs0',yr,i,' ') = fs0_.L(i);
solution(bal,'ms0',yr,i,m) = ms0_.L(i,m);
solution(bal,'y0',yr,i,' ') = y0_.L(i);
solution(bal,'id0',yr,i,j) = id0_.L(i,j);
solution(bal,'fd0',yr,i,fd) = fd0_.L(i,fd);
solution(bal,'va0',yr,va,j) = va0_.L(va,j);
solution(bal,'a0',yr,i,' ') = a0_.L(i);
solution(bal,'x0',yr,i,' ') = x0_.L(i);
solution(bal,'m0',yr,i,' ') = m0_.L(i);
solution(bal,'md0',yr,m,i) = md0_.L(m,i);

* Report total pct deviation between methods and from the benchmark.

report(yr,u,bal)$sum((uu,uuu), bench(u,yr,uu,uuu)) = 100 *
			(sum((uu,uuu)$bench(u,yr,uu,uuu), solution(bal,u,yr,uu,uuu))/sum((uu,uuu), bench(u,yr,uu,uuu)) - 1);

););

report(yr,u,'pctdev_method')$sum((uu,uuu),solution('ls',u,yr,uu,uuu)) = 100 * 
			(sum((uu,uuu)$solution('ls',u,yr,uu,uuu), solution('huber',u,yr,uu,uuu))/sum((uu,uuu), solution('ls',u,yr,uu,uuu)) - 1);

display report;

* Output the report to the loadpoint directory:

execute_unload 'temp\loadpoint\comparematbal.gdx' report;
execute 'gdxxrw.exe i=temp\loadpoint\comparematbal.gdx o=temp\loadpoint\comparematbal.xlsx par=report rng=compare! rdim=3 cdim=0';

abort$(smax(yr, report(yr,' ','huber'))>2) "Huber matrix balancing routine infeasible for at least one year.";
abort$(smax(yr, report(yr,' ','ls'))>2) "LS matrix balancing routine infeasible for at least one year.";

* Delete loadpoint files in root directory:

execute 'del balance_huber_p.gdx balance_ls_p.gdx';

* Reset benchmark parameters in accordance to selected matrix balancing
* routine:

ys_0(yr,j,i) = solution('%matbal%','ys0',yr,j,i);
fs_0(yr,i) = solution('%matbal%','fs0',yr,i,' ');
ms_0(yr,i,m) = solution('%matbal%','ms0',yr,i,m);
y_0(yr,i) = solution('%matbal%','y0',yr,i,' ');
id_0(yr,i,j) = solution('%matbal%','id0',yr,i,j);
fd_0(yr,i,fd) = solution('%matbal%','fd0',yr,i,fd);
va_0(yr,va,j) = solution('%matbal%','va0',yr,va,j);
a_0(yr,i) = solution('%matbal%','a0',yr,i,' ');
x_0(yr,i) = solution('%matbal%','x0',yr,i,' ');
m_0(yr,i) = solution('%matbal%','m0',yr,i,' ');
md_0(yr,m,i) = solution('%matbal%','md0',yr,m,i);
bopdef_0(yr) = sum(i$a_0(yr,i), m_0(yr,i)-x_0(yr,i));

* Verify new parameters satisfy accounting identities:

parameter	profit	Zero profit conditions,
		market	Market clearance condition;

s_0(yr,j) = sum(i,ys_0(yr,j,i));
profit(yr,j,"Y")$s_0(yr,j) = sum(i,ys_0(yr,j,i) - id_0(yr,i,j)) - sum(va,va_0(yr,va,j));
profit(yr,i,"A")$a_0(yr,i) = a_0(yr,i)*(1-ta_0(yr,i)) + x_0(yr,i) - y_0(yr,i) - m_0(yr,i)*(1+tm_0(yr,i)) - sum(m, md_0(yr,m,i));
market(yr,i,"PA")$a_0(yr,i) = a_0(yr,i) - sum(fd,fd_0(yr,i,fd)) - sum(j$s_0(yr,j),id_0(yr,i,j));
market(yr,i,"PY")$s_0(yr,i) = sum(j$s_0(yr,j),ys_0(yr,j,i)) + fs_0(yr,i) - y_0(yr,i) - sum(m,ms_0(yr,i,m));

display profit,market;

* Abort calibration procedure if micro-consistency check fails:

abort$(smax((yr,i), profit(yr,i,'Y'))>1e-7) "Y ZP is out of balance";
abort$(smax((yr,i), profit(yr,i,'A'))>1e-7) "A ZP is out of balance";
abort$(smax((yr,i), market(yr,i,'PY'))>1e-7) "PY market is out of balance";
abort$(smax((yr,i), market(yr,i,'PA'))>1e-7) "PA market is out of balance";

* Identify and report negative values:

parameter n_ys0; n_ys0(yr,j,i) = min(0,ys_0(yr,j,i));
parameter n_id0; n_id0(yr,i,j) = min(0,id_0(yr,i,j));
parameter n_va0; n_va0(yr,va,j) = min(0,va_0(yr,va,j));
parameter n_x0; n_x0(yr,i) = min(0,x_0(yr,i));
parameter n_y0; n_y0(yr,i) = min(0,y_0(yr,i));
parameter n_ms0; n_ms0(yr,i,m) = min(0,ms_0(yr,i,m));
parameter n_m0; n_m0(yr,i) = min(0,m_0(yr,i));
parameter n_md0; n_md0(yr,m,i) = min(0,md_0(yr,m,i));

abort$(	card(n_ys0)+card(n_id0)+card(n_va0)+card(n_x0)+
	card(n_y0)+card(n_ms0)+	card(n_m0)+card(n_md0)) "Error: negative entries.";

* ----------------------------------------------------------------------
* 	Verify balancing routine solution with a CGE accounting model:
* ----------------------------------------------------------------------

$include nationalmodel.gms
accounting.workspace = 100;
accounting.iterlim = 0;
$include 'temp\accounting.gen'
solve accounting using mcp;
abort$(accounting.objval>1e-5) "Error in benchmark calibration.";

* ----------------------------------------------------------------------
* 	Output calibrated parameters:
* ----------------------------------------------------------------------

execute_unload 'temp\gdx\national_cgeparm_bal_%sectors%.gdx' y_0,ys_0,fs_0,id_0,fd_0,va_0,ts_0,m_0,x_0,mrg_0,trn_0,duty_0,sbd_0,tax_0,ms_0,md_0,s_0,a_0,bopdef_0,ta_0,tm_0,yr,i,va,fd,ts,m;