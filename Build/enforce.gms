$title Matrix balancing routine for enforcing parameter values

* Dataset directory structure:

$if not set dsdir 	$set dsdir datasets\

* Output parameters for a single year:

$if not set year	$set year 2014

* Declare sectoring scheme used:

$if not set sectors	$set sectors eng

* Program only works for calibto == seds, no:

$if not set calibto	$set calibto seds

* Define environment variable as switch for calibration checks:

$if not set calibsw	$set calibsw no

* Define loss function (huber, ls):

$if not set matbal	$set matbal ls

* Stop program if reference case is sufficient:

$if %calibto% == no $exit

* -------------------------------------------------------------------
* Read in core regionalized blueNOTE dataset:
* -------------------------------------------------------------------

set	yr	Years of IO data,
	r	States,
	s	Goods\sectors (national data),
	gm(s)	Margin related sectors,
 	m	Margins (trade or transport);

$gdxin '%dsdir%blueNOTE_%sectors%.gdx'
$loaddc yr r s m gm
alias(s,g),(r,rr);

parameter	ys0_(yr,r,g,s)	Sectoral supply,
		id0_(yr,r,s,g)	Intermediate demand,
		ld0_(yr,r,s)	Labor demand,
		kd0_(yr,r,s)	Capital demand,
		m0_(yr,r,s)	Imports,
		x0_(yr,r,s)	Exports of goods and services,
		rx0_(yr,r,s)	Re-exports of goods and services,
		md0_(yr,r,m,s)	Total margin demand,
		nm0_(yr,r,m,g)	Margin demand from national market,
		dm0_(yr,r,m,g)	Margin supply from local market,
		s0_(yr,r,s)	Aggregate supply,
		a0_(yr,r,s)	Armington supply,
		ta0_(yr,r,s)	Tax net subsidy rate on intermediate demand,
		tm0_(yr,r,s)	Import tariff,
		cd0_(yr,r,s)	Final demand,
		c0_(yr,r)	Aggregate final demand,
		yh0_(yr,r,s)	Household production,
		fe0_(yr,r)	Factor endowments,
		bopdef0_(yr,r)	Balance of payments,
		hhadj_(yr,r)	Household adjustment,
		g0_(yr,r,s)	Government demand,
		i0_(yr,r,s)	Investment demand,
		xn0_(yr,r,g)	Regional supply to national market,
		xd0_(yr,r,g)	Regional supply to local market,
		dd0_(yr,r,g)	Regional demand from local  market,
		nd0_(yr,r,g)	Regional demand from national market;

* Production data: 

$loaddc ys0_ ld0_ kd0_ id0_

* Consumption data:

$loaddc yh0_ fe0_ cd0_ c0_ i0_ g0_ bopdef0_ hhadj_

* Trade data:

$loaddc s0_ xd0_ xn0_ x0_ rx0_ a0_ nd0_ dd0_ m0_ ta0_ tm0_

* Margins:

$loaddc md0_ nm0_ dm0_

* -------------------------------------------------------------------
* Define national totals:
* -------------------------------------------------------------------

parameter	ys0nat,m0nat,x0nat,va0nat,i0nat,g0nat,cd0nat;

ys0nat(yr,s,g) = sum(r, ys0_(yr,r,s,g));
m0nat(yr,g) = sum(r, m0_(yr,r,g));
x0nat(yr,g) = sum(r, x0_(yr,r,g));
va0nat(yr,g) = sum(r, ld0_(yr,r,g) + kd0_(yr,r,g));
i0nat(yr,g) = sum(r, i0_(yr,r,g));
g0nat(yr,g) = sum(r, g0_(yr,r,g));
cd0nat(yr,g) = sum(r, cd0_(yr,r,g));

parameter	dataconschk	Consistency check on re-calibrated data;

dataconschk(r,s,'ys0','old') = sum(g, ys0_('%year%',r,s,g));
dataconschk(r,g,'id0','old') = sum(s, id0_('%year%',r,g,s));
dataconschk(r,s,'va0','old') = ld0_('%year%',r,s) + kd0_('%year%',r,s);

dataconschk(r,g,'i0','old') = i0_('%year%',r,g);
dataconschk(r,g,'g0','old') = g0_('%year%',r,g);
dataconschk(r,g,'cd0','old') = cd0_('%year%',r,g);
dataconschk(r,g,'yh0','old') = yh0_('%year%',r,g);
dataconschk(r,'total','hhadj','old') = hhadj_('%year%',r);
dataconschk(r,'total','bop','old') = bopdef0_('%year%',r);

dataconschk(r,g,'s0','old') = s0_('%year%',r,g);
dataconschk(r,g,'xd0','old') = xd0_('%year%',r,g);
dataconschk(r,g,'xn0','old') = xn0_('%year%',r,g);
dataconschk(r,g,'x0','old') = x0_('%year%',r,g);
dataconschk(r,g,'rx0','old') = rx0_('%year%',r,g);
dataconschk(r,g,'a0','old') = a0_('%year%',r,g);
dataconschk(r,g,'nd0','old') = nd0_('%year%',r,g);
dataconschk(r,g,'dd0','old') = dd0_('%year%',r,g);
dataconschk(r,g,'m0','old') = m0_('%year%',r,g);

dataconschk(r,g,'md0','old') = sum(m, md0_('%year%',r,m,g));
dataconschk(r,g,'nm0','old') = sum(m, nm0_('%year%',r,m,g));
dataconschk(r,g,'dm0','old') = sum(m, dm0_('%year%',r,m,g));

* -------------------------------------------------------------------
* Impose outside data: SEDS
* -------------------------------------------------------------------

* Note that in this first pass, I refrain from separating the energy sector by
* technology type (ie. coal vs. nuclear) to match my current model
* framework. The basic totals I am interested in from SEDS are margins (markups
* from consumer vs. wholesale electricity pricing) and energy demands which
* correspond well to emissions data.

$if %calibto% == seds $include seds.gms

* New sector name: ds -- includes separation of oil and gas sectors.
* Parameters altered: ys0, cd0, md0, id0, x0(ele_uti), m0(ele_uti) to match SEDS
* totals.

* -------------------------------------------------------------------
* Recalibrate dataset to match totals using the Huber method:
* -------------------------------------------------------------------

* Apply a fine filter to the dataset: drop values which are less than .01%
* of the average value across all regions.

parameter	trace	Debug check on calculations,
		zerotol	Tolerance level / 3 /;

* Number of elements in each parameter before filter is applied:

trace(yr,ds,'ld0','before') = sum((r)$ld0(yr,r,ds),1);
trace(yr,ds,'kd0','before') = sum((r)$kd0(yr,r,ds),1);
trace(yr,dg,'m0','before') = sum((r)$m0(yr,r,dg),1);
trace(yr,dg,'x0','before') = sum((r)$x0(yr,r,dg),1);
trace(yr,dg,'rx0','before') = sum((r)$rx0(yr,r,dg),1);
trace(yr,dg,'s0','before') = sum((r)$s0(yr,r,dg),1);
trace(yr,dg,'a0','before') = sum((r)$a0(yr,r,dg),1);
trace(yr,dg,'cd0','before') = sum((r)$cd0(yr,r,dg),1);
trace(yr,dg,'yh0','before') = sum((r)$yh0(yr,r,dg),1);
trace(yr,dg,'g0','before') = sum((r)$g0(yr,r,dg),1);
trace(yr,dg,'i0','before') = sum((r)$i0(yr,r,dg),1);
trace(yr,dg,'xn0','before') = sum((r)$xn0(yr,r,dg),1);
trace(yr,dg,'xd0','before') = sum((r)$xd0(yr,r,dg),1);
trace(yr,dg,'dd0','before') = sum((r)$dd0(yr,r,dg),1);
trace(yr,dg,'nd0','before') = sum((r)$nd0(yr,r,dg),1);
trace(yr,ds,'ys0','before') = sum((r,dg)$ys0(yr,r,ds,dg),1);
trace(yr,dg,'id0','before') = sum((r,ds)$id0(yr,r,dg,ds),1);
trace(yr,dg,'md0','before') = sum((r,m)$md0(yr,r,m,dg),1);
trace(yr,dg,'nm0','before') = sum((r,m)$nm0(yr,r,m,dg),1);
trace(yr,dg,'dm0','before') = sum((r,m)$dm0(yr,r,m,dg),1);

* Average value of each parameter:

trace(yr,ds,'ld0','avg')$trace(yr,ds,'ld0','before') = sum((r),ld0(yr,r,ds))/trace(yr,ds,'ld0','before');
trace(yr,ds,'kd0','avg')$trace(yr,ds,'kd0','before') = sum((r),kd0(yr,r,ds))/trace(yr,ds,'kd0','before');
trace(yr,dg,'m0','avg')$trace(yr,dg,'m0','before') = sum((r),m0(yr,r,dg))/trace(yr,dg,'m0','before');
trace(yr,dg,'x0','avg')$trace(yr,dg,'x0','before') = sum((r),x0(yr,r,dg))/trace(yr,dg,'x0','before');
trace(yr,dg,'rx0','avg')$trace(yr,dg,'rx0','before') = sum((r),rx0(yr,r,dg))/trace(yr,dg,'rx0','before');
trace(yr,dg,'s0','avg')$trace(yr,dg,'s0','before') = sum((r),s0(yr,r,dg))/trace(yr,dg,'s0','before');
trace(yr,dg,'a0','avg')$trace(yr,dg,'a0','before') = sum((r),a0(yr,r,dg))/trace(yr,dg,'a0','before');
trace(yr,dg,'cd0','avg')$trace(yr,dg,'cd0','before') = sum((r),cd0(yr,r,dg))/trace(yr,dg,'cd0','before');
trace(yr,dg,'yh0','avg')$trace(yr,dg,'yh0','before') = sum((r),yh0(yr,r,dg))/trace(yr,dg,'yh0','before');
trace(yr,dg,'g0','avg')$trace(yr,dg,'g0','before') = sum((r),g0(yr,r,dg))/trace(yr,dg,'g0','before');
trace(yr,dg,'i0','avg')$trace(yr,dg,'i0','before') = sum((r),i0(yr,r,dg))/trace(yr,dg,'i0','before');
trace(yr,dg,'xn0','avg')$trace(yr,dg,'xn0','before') = sum((r),xn0(yr,r,dg))/trace(yr,dg,'xn0','before');
trace(yr,dg,'xd0','avg')$trace(yr,dg,'xd0','before') = sum((r),xd0(yr,r,dg))/trace(yr,dg,'xd0','before');
trace(yr,dg,'dd0','avg')$trace(yr,dg,'dd0','before') = sum((r),dd0(yr,r,dg))/trace(yr,dg,'dd0','before');
trace(yr,dg,'nd0','avg')$trace(yr,dg,'nd0','before') = sum((r),nd0(yr,r,dg))/trace(yr,dg,'nd0','before');
trace(yr,ds,'ys0','avg')$trace(yr,ds,'ys0','before') = sum((r,dg),ys0(yr,r,ds,dg))/trace(yr,ds,'ys0','before');
trace(yr,dg,'id0','avg')$trace(yr,dg,'id0','before') = sum((r,ds),id0(yr,r,dg,ds))/trace(yr,dg,'id0','before');
trace(yr,dg,'md0','avg')$trace(yr,dg,'md0','before') = sum((r,m),md0(yr,r,m,dg))/trace(yr,dg,'md0','before');
trace(yr,dg,'nm0','avg')$trace(yr,dg,'nm0','before') = sum((r,m),nm0(yr,r,m,dg))/trace(yr,dg,'nm0','before');
trace(yr,dg,'dm0','avg')$trace(yr,dg,'dm0','before') = sum((r,m),dm0(yr,r,m,dg))/trace(yr,dg,'dm0','before');

ld0(yr,r,ds)$(round(ld0(yr,r,ds)/trace(yr,ds,'ld0','avg'),zerotol)=0) = 0;
kd0(yr,r,ds)$(round(kd0(yr,r,ds)/trace(yr,ds,'kd0','avg'),zerotol)=0) = 0;
m0(yr,r,dg)$(round(m0(yr,r,dg)/trace(yr,dg,'m0','avg'),zerotol)=0) = 0;
x0(yr,r,dg)$(round(x0(yr,r,dg)/trace(yr,dg,'x0','avg'),zerotol)=0) = 0;
rx0(yr,r,dg)$(round(rx0(yr,r,dg)/trace(yr,dg,'rx0','avg'),zerotol)=0) = 0;
s0(yr,r,dg)$(round(s0(yr,r,dg)/trace(yr,dg,'s0','avg'),zerotol)=0) = 0;
a0(yr,r,dg)$(round(a0(yr,r,dg)/trace(yr,dg,'a0','avg'),zerotol)=0) = 0;
cd0(yr,r,dg)$(round(cd0(yr,r,dg)/trace(yr,dg,'cd0','avg'),zerotol)=0) = 0;
yh0(yr,r,dg)$(round(yh0(yr,r,dg)/trace(yr,dg,'yh0','avg'),zerotol)=0) = 0;
g0(yr,r,dg)$(round(g0(yr,r,dg)/trace(yr,dg,'g0','avg'),zerotol)=0) = 0;
i0(yr,r,dg)$(round(i0(yr,r,dg)/trace(yr,dg,'i0','avg'),zerotol)=0) = 0;
xn0(yr,r,dg)$(round(xn0(yr,r,dg)/trace(yr,dg,'xn0','avg'),zerotol)=0) = 0;
xd0(yr,r,dg)$(round(xd0(yr,r,dg)/trace(yr,dg,'xd0','avg'),zerotol)=0) = 0;
dd0(yr,r,dg)$(round(dd0(yr,r,dg)/trace(yr,dg,'dd0','avg'),zerotol)=0) = 0;
nd0(yr,r,dg)$(round(nd0(yr,r,dg)/trace(yr,dg,'nd0','avg'),zerotol)=0) = 0;
ys0(yr,r,ds,dg)$(round(ys0(yr,r,ds,dg)/trace(yr,ds,'ys0','avg'),zerotol)=0) = 0;
id0(yr,r,dg,ds)$(round(id0(yr,r,dg,ds)/trace(yr,dg,'id0','avg'),zerotol)=0) = 0;
md0(yr,r,m,dg)$(round(md0(yr,r,m,dg)/trace(yr,dg,'md0','avg'),zerotol)=0) = 0;
nm0(yr,r,m,dg)$(round(nm0(yr,r,m,dg)/trace(yr,dg,'nm0','avg'),zerotol)=0) = 0;
dm0(yr,r,m,dg)$(round(dm0(yr,r,m,dg)/trace(yr,dg,'dm0','avg'),zerotol)=0) = 0;

* Also, drop tiny numbers:

ld0(yr,r,ds)$(not round(ld0(yr,r,ds),7)) = 0;
kd0(yr,r,ds)$(not round(kd0(yr,r,ds),7)) = 0;
m0(yr,r,dg)$(not round(m0(yr,r,dg),7)) = 0;
x0(yr,r,dg)$(not round(x0(yr,r,dg),7)) = 0;
rx0(yr,r,dg)$(not round(rx0(yr,r,dg),7)) = 0;
s0(yr,r,dg)$(not round(s0(yr,r,dg),7)) = 0;
a0(yr,r,dg)$(not round(a0(yr,r,dg),7)) = 0;
cd0(yr,r,dg)$(not round(cd0(yr,r,dg),7)) = 0;
yh0(yr,r,dg)$(not round(yh0(yr,r,dg),7)) = 0;
g0(yr,r,dg)$(not round(g0(yr,r,dg),7)) = 0;
i0(yr,r,dg)$(not round(i0(yr,r,dg),7)) = 0;
xn0(yr,r,dg)$(not round(xn0(yr,r,dg),7)) = 0;
xd0(yr,r,dg)$(not round(xd0(yr,r,dg),7)) = 0;
dd0(yr,r,dg)$(not round(dd0(yr,r,dg),7)) = 0;
nd0(yr,r,dg)$(not round(nd0(yr,r,dg),7)) = 0;
ys0(yr,r,ds,dg)$(not round(ys0(yr,r,ds,dg),7)) = 0;
id0(yr,r,dg,ds)$(not round(id0(yr,r,dg,ds),7)) = 0;
md0(yr,r,m,dg)$(not round(md0(yr,r,m,dg),7)) = 0;
nm0(yr,r,m,dg)$(not round(nm0(yr,r,m,dg),7)) = 0;
dm0(yr,r,m,dg)$(not round(dm0(yr,r,m,dg),7)) = 0;

trace(yr,ds,'ld0','after') = sum((r)$ld0(yr,r,ds),1);
trace(yr,ds,'kd0','after') = sum((r)$kd0(yr,r,ds),1);
trace(yr,dg,'m0','after') = sum((r)$m0(yr,r,dg),1);
trace(yr,dg,'x0','after') = sum((r)$x0(yr,r,dg),1);
trace(yr,dg,'rx0','after') = sum((r)$rx0(yr,r,dg),1);
trace(yr,dg,'s0','after') = sum((r)$s0(yr,r,dg),1);
trace(yr,dg,'a0','after') = sum((r)$a0(yr,r,dg),1);
trace(yr,dg,'cd0','after') = sum((r)$cd0(yr,r,dg),1);
trace(yr,dg,'yh0','after') = sum((r)$yh0(yr,r,dg),1);
trace(yr,dg,'g0','after') = sum((r)$g0(yr,r,dg),1);
trace(yr,dg,'i0','after') = sum((r)$i0(yr,r,dg),1);
trace(yr,dg,'xn0','after') = sum((r)$xn0(yr,r,dg),1);
trace(yr,dg,'xd0','after') = sum((r)$xd0(yr,r,dg),1);
trace(yr,dg,'dd0','after') = sum((r)$dd0(yr,r,dg),1);
trace(yr,dg,'nd0','after') = sum((r)$nd0(yr,r,dg),1);
trace(yr,ds,'ys0','after') = sum((r,dg)$ys0(yr,r,ds,dg),1);
trace(yr,dg,'id0','after') = sum((r,ds)$id0(yr,r,dg,ds),1);
trace(yr,dg,'md0','after') = sum((r,m)$md0(yr,r,m,dg),1);
trace(yr,dg,'nm0','after') = sum((r,m)$nm0(yr,r,m,dg),1);
trace(yr,dg,'dm0','after') = sum((r,m)$dm0(yr,r,m,dg),1);

* Check on the number of lost parameter values:

alias(pm,*);
parameter	zeroed	Number of zeroed elements in filter;

zeroed(yr,'before')$(not sameas(yr,'2015')) = sum((pm,dg), trace(yr,dg,pm,'before'));
zeroed(yr,'after')$(not sameas(yr,'2015')) = sum((pm,dg), trace(yr,dg,pm,'after'));
zeroed(yr,'diff') = zeroed(yr,'before') - zeroed(yr,'after');

* -------------------------------------------------------------------------
* Write a re-calibration routine which minimally shifts data to maintain
* micro-consistency.
* -------------------------------------------------------------------------

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

set	mat 	Select parameters for huber objective /ys0,id0/;

set	nonzero(mat,r,*,*)	Nonzeros in the reference data,
	zeros(mat,r,*,*)	Zeros in the reference data;

parameter	zeropenalty	Penalty for imposing non-zero elements /1e5/;

set	eneg(s)		Energy sectors in national data
			/ oil_oil, ele_uti, ref_pet, col_min /;

nonnegative
variables		YS, ID, LD, KD		Production variables,
			ARM, ND, DD, IMP	Trade variables,
			SUP, XD, XN, XPT, RX	Supply variables,
			NM, DM, MARD		Margin variables,
			YH, CD, INV, GD		Demand variables,
			X1, X2, X3		Percentage deviations;

variables		OBJ			Objective variable,
			BOP(r)			Balance of payments;
*			HHAD(r)			Household adjustment;

equations		obj_ls			Least squares objective definition,
			obj_huber		Hybrid huber objective definition,

			zp_y, zp_a, zp_x	Zero Profit Conditions,
			zp_ms, zp_c

			mc_py, mc_pa, mc_pn 	Market Clearance Conditions,
			mc_pfx, mc_pm, mc_pfx,
			mc_pd,

			incbal			Income balance,

			expdef			Gross exports must be greater than re-exports,

			netgenbalpos1		Net generation of electricity balancing,
			netgenbalpos2		Net generation of electricity balancing,
			netgenbalneg1		Net generation of electricity balancing,
			netgenbalneg2		Net generation of electricity balancing,

			natys0,natm0,natx0	Verify regional totals eq national totals,
			natva,nati0,natg0,
			natc0,

			demtotup,demtotlo	Verify energy demands match SEDS,
			x2def, x3def		Huber constraints;
				
			
parameter	ys0loop, id0loop, ld0loop, kd0loop,
		ta, a0loop, nd0loop, dd0loop, tm, m0loop,
		s0loop, xd0loop, xn0loop, x0loop, rx0loop,
		nm0loop, dm0loop, md0loop,
		cd0loop, c0loop, g0loop, i0loop, yh0loop, bopdef0loop, hhadjloop,
		netgenloop, nat_ys, nat_m, nat_x, nat_va, nat_i, nat_g, nat_c,
		edloop;

* Huber method: additional parameters needed if using Huber's matrix
* balancing routine:

parameter	v0(mat,r,*,*)	matrix values;

parameter       gammab   Lower bound cross-over tolerance /0.5/,
		thetab   Upper bound cross-over tolerance /0.25/;

$macro	MV(mat,r,ds,dg) (YS(r,ds,dg)$sameas(mat,"ys0") + ID(r,ds,dg)$sameas(mat,"id0"))

x2def(nonzero(mat,r,ds,dg))..   X2(mat,r,ds,dg) + X1(mat,r,ds,dg) =g= (MV(mat,r,ds,dg)/v0(mat,r,ds,dg)-1);
x3def(nonzero(mat,r,ds,dg))..   X3(mat,r,ds,dg) - X2(mat,r,ds,dg) =g= (1-MV(mat,r,ds,dg)/v0(mat,r,ds,dg));

obj_huber..  OBJ =e= 	sum(nonzero(mat,r,ds,dg), abs(v0(mat,r,ds,dg)) * 
	                (sqr(X2(mat,r,ds,dg)) + 2*thetab*X1(mat,r,ds,dg) - 
			2*gammab*(1-gammab)*log(1-gammab-X3(mat,r,ds,dg)))) +

			sum((r,ds)$ld0loop(r,ds), abs(ld0loop(r,ds)) * sqr(LD(r,ds) / ld0loop(r,ds) - 1)) +
			sum((r,ds)$kd0loop(r,ds), abs(kd0loop(r,ds)) * sqr(KD(r,ds) / kd0loop(r,ds) - 1)) +
			sum((r,dg)$a0loop(r,dg), abs(a0loop(r,dg)) * sqr(ARM(r,dg) / a0loop(r,dg) - 1)) +
			sum((r,dg)$nd0loop(r,dg), abs(nd0loop(r,dg)) * sqr(ND(r,dg) / nd0loop(r,dg) - 1)) +
			sum((r,dg)$dd0loop(r,dg), abs(dd0loop(r,dg)) * sqr(DD(r,dg) / dd0loop(r,dg) - 1)) +
			sum((r,dg)$m0loop(r,dg), abs(m0loop(r,dg)) * sqr(IMP(r,dg) / m0loop(r,dg) - 1)) +
			sum((r,dg)$s0loop(r,dg), abs(s0loop(r,dg)) * sqr(SUP(r,dg) / s0loop(r,dg) - 1)) +
			sum((r,dg)$xd0loop(r,dg), abs(xd0loop(r,dg)) * sqr(XD(r,dg) / xd0loop(r,dg) - 1)) +
			sum((r,dg)$xn0loop(r,dg), abs(xn0loop(r,dg)) * sqr(XN(r,dg) / xn0loop(r,dg) - 1)) +
			sum((r,dg)$x0loop(r,dg), abs(x0loop(r,dg)) * sqr(XPT(r,dg) / x0loop(r,dg) - 1)) +
			sum((r,dg)$rx0loop(r,dg), abs(rx0loop(r,dg)) * sqr(RX(r,dg) / rx0loop(r,dg) - 1)) +
			sum((r,m,dg)$nm0loop(r,m,dg), abs(nm0loop(r,m,dg)) * sqr(NM(r,m,dg) / nm0loop(r,m,dg) - 1)) +
			sum((r,m,dg)$dm0loop(r,m,dg), abs(dm0loop(r,m,dg)) * sqr(DM(r,m,dg) / dm0loop(r,m,dg) - 1)) +
			sum((r,m,dg)$md0loop(r,m,dg), abs(md0loop(r,m,dg)) * sqr(MARD(r,m,dg) / md0loop(r,m,dg) - 1)) +
			sum((r,dg)$yh0loop(r,dg), abs(yh0loop(r,dg)) * sqr(YH(r,dg) / yh0loop(r,dg) - 1)) +
			sum((r,dg)$cd0loop(r,dg), abs(cd0loop(r,dg)) * sqr(CD(r,dg) / cd0loop(r,dg) - 1)) +
			sum((r,dg)$i0loop(r,dg), abs(i0loop(r,dg)) * sqr(INV(r,dg) / i0loop(r,dg) - 1)) +
			sum((r,dg)$g0loop(r,dg), abs(g0loop(r,dg)) * sqr(GD(r,dg) / g0loop(r,dg) - 1)) +
			sum((r)$bopdef0loop(r), abs(bopdef0loop(r)) * sqr(BOP(r) / bopdef0loop(r) - 1)) +
*			sum((r)$hhadjloop(r), abs(hhadjloop(r)) * sqr(HHAD(r) / hhadjloop(r) - 1)) +
		zeropenalty * (
			sum((r,ds,dg)$(not ys0loop(r,ds,dg)), YS(r,ds,dg)) +
			sum((r,dg,ds)$(not id0loop(r,dg,ds)), ID(r,dg,ds)) +
			sum((r,ds)$(not ld0loop(r,ds)), LD(r,ds)) +
			sum((r,ds)$(not kd0loop(r,ds)), KD(r,ds)) +
			sum((r,dg)$(not a0loop(r,dg)), ARM(r,dg)) +
			sum((r,dg)$(not nd0loop(r,dg)), ND(r,dg)) +
			sum((r,dg)$(not dd0loop(r,dg)), DD(r,dg)) +
			sum((r,dg)$(not m0loop(r,dg)), IMP(r,dg)) +
			sum((r,dg)$(not s0loop(r,dg)), SUP(r,dg)) +
			sum((r,dg)$(not xd0loop(r,dg)), XD(r,dg)) +
			sum((r,dg)$(not xn0loop(r,dg)), XN(r,dg)) +
			sum((r,dg)$(not x0loop(r,dg)), XPT(r,dg)) +
			sum((r,dg)$(not rx0loop(r,dg)), RX(r,dg)) +
			sum((r,m,dg)$(not nm0loop(r,m,dg)), NM(r,m,dg)) +
			sum((r,m,dg)$(not dm0loop(r,m,dg)), DM(r,m,dg)) +
			sum((r,m,dg)$(not md0loop(r,m,dg)), MARD(r,m,dg)) +
			sum((r,dg)$(not yh0loop(r,dg)), YH(r,dg)) +
			sum((r,dg)$(not cd0loop(r,dg)), CD(r,dg)) +
			sum((r,dg)$(not i0loop(r,dg)), INV(r,dg)) +
			sum((r,dg)$(not g0loop(r,dg)), GD(r,dg)));

* Least squares:

obj_ls..	OBJ =e= sum((r,ds,dg)$ys0loop(r,ds,dg), abs(ys0loop(r,ds,dg)) * sqr(YS(r,ds,dg) / ys0loop(r,ds,dg) - 1)) +
			sum((r,dg,ds)$id0loop(r,dg,ds), abs(id0loop(r,dg,ds)) * sqr(ID(r,dg,ds) / id0loop(r,dg,ds) - 1)) +
			sum((r,ds)$ld0loop(r,ds), abs(ld0loop(r,ds)) * sqr(LD(r,ds) / ld0loop(r,ds) - 1)) +
			sum((r,ds)$kd0loop(r,ds), abs(kd0loop(r,ds)) * sqr(KD(r,ds) / kd0loop(r,ds) - 1)) +
			sum((r,dg)$a0loop(r,dg), abs(a0loop(r,dg)) * sqr(ARM(r,dg) / a0loop(r,dg) - 1)) +
			sum((r,dg)$nd0loop(r,dg), abs(nd0loop(r,dg)) * sqr(ND(r,dg) / nd0loop(r,dg) - 1)) +
			sum((r,dg)$dd0loop(r,dg), abs(dd0loop(r,dg)) * sqr(DD(r,dg) / dd0loop(r,dg) - 1)) +
			sum((r,dg)$m0loop(r,dg), abs(m0loop(r,dg)) * sqr(IMP(r,dg) / m0loop(r,dg) - 1)) +
			sum((r,dg)$s0loop(r,dg), abs(s0loop(r,dg)) * sqr(SUP(r,dg) / s0loop(r,dg) - 1)) +
			sum((r,dg)$xd0loop(r,dg), abs(xd0loop(r,dg)) * sqr(XD(r,dg) / xd0loop(r,dg) - 1)) +
			sum((r,dg)$xn0loop(r,dg), abs(xn0loop(r,dg)) * sqr(XN(r,dg) / xn0loop(r,dg) - 1)) +
			sum((r,dg)$x0loop(r,dg), abs(x0loop(r,dg)) * sqr(XPT(r,dg) / x0loop(r,dg) - 1)) +
			sum((r,dg)$rx0loop(r,dg), abs(rx0loop(r,dg)) * sqr(RX(r,dg) / rx0loop(r,dg) - 1)) +
			sum((r,m,dg)$nm0loop(r,m,dg), abs(nm0loop(r,m,dg)) * sqr(NM(r,m,dg) / nm0loop(r,m,dg) - 1)) +
			sum((r,m,dg)$dm0loop(r,m,dg), abs(dm0loop(r,m,dg)) * sqr(DM(r,m,dg) / dm0loop(r,m,dg) - 1)) +
			sum((r,m,dg)$md0loop(r,m,dg), abs(md0loop(r,m,dg)) * sqr(MARD(r,m,dg) / md0loop(r,m,dg) - 1)) +
			sum((r,dg)$yh0loop(r,dg), abs(yh0loop(r,dg)) * sqr(YH(r,dg) / yh0loop(r,dg) - 1)) +
			sum((r,dg)$cd0loop(r,dg), abs(cd0loop(r,dg)) * sqr(CD(r,dg) / cd0loop(r,dg) - 1)) +
			sum((r,dg)$i0loop(r,dg), abs(i0loop(r,dg)) * sqr(INV(r,dg) / i0loop(r,dg) - 1)) +
			sum((r,dg)$g0loop(r,dg), abs(g0loop(r,dg)) * sqr(GD(r,dg) / g0loop(r,dg) - 1)) +
			sum((r)$bopdef0loop(r), abs(bopdef0loop(r)) * sqr(BOP(r) / bopdef0loop(r) - 1)) +
*			sum((r)$hhadjloop(r), abs(hhadjloop(r)) * sqr(HHAD(r) / hhadjloop(r) - 1)) +
		zeropenalty * (
			sum((r,ds,dg)$(not ys0loop(r,ds,dg)), sqr(YS(r,ds,dg))) +
			sum((r,dg,ds)$(not id0loop(r,dg,ds)), sqr(ID(r,dg,ds))) +
			sum((r,ds)$(not ld0loop(r,ds)), sqr(LD(r,ds))) +
			sum((r,ds)$(not kd0loop(r,ds)), sqr(KD(r,ds))) +
			sum((r,dg)$(not a0loop(r,dg)), sqr(ARM(r,dg))) +
			sum((r,dg)$(not nd0loop(r,dg)), sqr(ND(r,dg))) +
			sum((r,dg)$(not dd0loop(r,dg)), sqr(DD(r,dg))) +
			sum((r,dg)$(not m0loop(r,dg)), sqr(IMP(r,dg))) +
			sum((r,dg)$(not s0loop(r,dg)), sqr(SUP(r,dg))) +
			sum((r,dg)$(not xd0loop(r,dg)), sqr(XD(r,dg))) +
			sum((r,dg)$(not xn0loop(r,dg)), sqr(XN(r,dg))) +
			sum((r,dg)$(not x0loop(r,dg)), sqr(XPT(r,dg))) +
			sum((r,dg)$(not rx0loop(r,dg)), sqr(RX(r,dg))) +
			sum((r,m,dg)$(not nm0loop(r,m,dg)), sqr(NM(r,m,dg))) +
			sum((r,m,dg)$(not dm0loop(r,m,dg)), sqr(DM(r,m,dg))) +
			sum((r,m,dg)$(not md0loop(r,m,dg)), sqr(MARD(r,m,dg))) +
			sum((r,dg)$(not yh0loop(r,dg)), sqr(YH(r,dg))) +
			sum((r,dg)$(not cd0loop(r,dg)), sqr(CD(r,dg))) +
			sum((r,dg)$(not i0loop(r,dg)), sqr(INV(r,dg))) +
			sum((r,dg)$(not g0loop(r,dg)), sqr(GD(r,dg))));

zp_y(r,ds)..	sum(dg, YS(r,ds,dg)) =e= sum(dg, ID(r,dg,ds)) + LD(r,ds) + KD(r,ds);
zp_a(r,dg)..	(1-ta(r,dg)) * ARM(r,dg) + RX(r,dg) =e= ND(r,dg) + DD(r,dg) + (1+tm(r,dg)) * IMP(r,dg) + sum(m, MARD(r,m,dg));
zp_x(r,dg)..	SUP(r,dg) + RX(r,dg) =e= XPT(r,dg) + XN(r,dg) + XD(r,dg);
zp_ms(r,m)..	sum(ds, NM(r,m,ds) + DM(r,m,ds)) =e= sum(dg, MARD(r,m,dg));

mc_py(r,dg)..	sum(ds, YS(r,ds,dg)) + YH(r,dg) =e= SUP(r,dg);
mc_pa(r,dg)..	ARM(r,dg) =e= sum(ds, ID(r,dg,ds)) + CD(r,dg) + GD(r,dg) + INV(r,dg);
mc_pd(r,dg)..	XD(r,dg) =e= sum(m, DM(r,m,dg)) + DD(r,dg);
mc_pn(dg)..	sum(r, XN(r,dg)) =e= sum((r,m), NM(r,m,dg)) + sum(r, ND(r,dg));
mc_pfx..	sum(r, BOP(r) + hhadjloop(r)) + sum((r,dg), XPT(r,dg)) =e= sum((r,dg), IMP(r,dg));

expdef(r,dg)..	XPT(r,dg) =g= RX(r,dg);

incbal(r)..	sum(dg, CD(r,dg) + GD(r,dg) + INV(r,dg)) =e=
		sum(dg, YH(r,dg)) + BOP(r) + hhadjloop(r) + sum(ds, LD(r,ds) + KD(r,ds)) + sum(dg, ta(r,dg)*ARM(r,dg) + tm(r,dg)*IMP(r,dg));

* Impose net generation constraints on national electricity trade if calibrating
* to SEDS data:

$if %calibto% == seds netgenbalpos1(r)$(netgenloop(r)>0)..	ND(r,'ele_uti') - XN(r,'ele_uti') =g= 0.5 * netgenloop(r);

$if %calibto% == seds netgenbalpos2(r)$(netgenloop(r)>0)..	ND(r,'ele_uti') - XN(r,'ele_uti') =l= 1.5 * netgenloop(r);

$if %calibto% == seds netgenbalneg1(r)$(netgenloop(r)<0)..	ND(r,'ele_uti') - XN(r,'ele_uti') =l= 0.5 * netgenloop(r);

$if %calibto% == seds netgenbalneg2(r)$(netgenloop(r)<0)..	ND(r,'ele_uti') - XN(r,'ele_uti') =g= 1.5 * netgenloop(r);

$if %calibto% == seds demtotup(r,demsec)..	sum(ioe, sum(mapdems(dg,demsec), ID(r,ioe,dg)) + CD(r,ioe)$sameas(demsec,'res')) =l= 1.5*sum(ioe, sum(mapioe(ioe,e), edloop(r,e,demsec)));

$if %calibto% == seds demtotlo(r,demsec)..	sum(ioe, sum(mapdems(dg,demsec), ID(r,ioe,dg)) + CD(r,ioe)$sameas(demsec,'res')) =g= 0.5*sum(ioe, sum(mapioe(ioe,e), edloop(r,e,demsec)));

* Verify regional parameters sum to national totals (for years other than
* 2015) for key parameters of non-energy sectors. SEDS data is used for
* energy totals.

natys0(s)$(not eneg(s))..	sum((r,dg), YS(r,s,dg)) =e= sum(g, nat_ys(s,g));

natx0(s)$(not eneg(s))..	sum(r, XPT(r,s)) =e= nat_x(s);

natm0(s)$(not eneg(s))..	sum(r, IMP(r,s)) =e= nat_m(s);

natva(s)$(not eneg(s))..	sum(r, LD(r,s) + KD(r,s)) =e= nat_va(s);

natg0(s)$(not eneg(s))..	sum(r, GD(r,s)) =e= nat_g(s);

nati0(s)$(not eneg(s))..	sum(r, INV(r,s)) =e= nat_i(s);

natc0(s)$(not eneg(s))..	sum(r, CD(r,s)) =e= nat_c(s);

$if %matbal% == huber model regcalib /obj_huber, expdef, zp_y, zp_a, zp_x, zp_ms, mc_py, mc_pa, mc_pn, mc_pfx, mc_pd, incbal, netgenbalpos1, netgenbalpos2, netgenbalneg1, netgenbalneg2, natx0, natm0, natva, natg0, nati0, natc0 /;

$if %matbal% == ls model regcalib /obj_ls, expdef, zp_y, zp_a, zp_x, zp_ms, mc_py, mc_pa, mc_pn, mc_pfx, mc_pd, incbal, netgenbalpos1, netgenbalpos2, netgenbalneg1, netgenbalneg2, natx0, natm0, natva, natg0, nati0, natc0 /;

* Declare preferred solvers:

option qcp = cplex;
option nlp = conopt;

* We could alternatively produce data for all years:
* loop(yr$(not sameas(yr,'2015')),

loop(yr$(sameas(yr,'%year%')),

* Define looping data:

ys0loop(r,ds,dg) = ys0(yr,r,ds,dg);
id0loop(r,dg,ds) = id0(yr,r,dg,ds);
ld0loop(r,dg) = ld0(yr,r,dg);
kd0loop(r,dg) = kd0(yr,r,dg);
a0loop(r,dg) = a0(yr,r,dg);
nd0loop(r,dg) = nd0(yr,r,dg);
dd0loop(r,dg) = dd0(yr,r,dg);
m0loop(r,dg) = m0(yr,r,dg);
s0loop(r,dg) = s0(yr,r,dg);
x0loop(r,dg) = x0(yr,r,dg);
xn0loop(r,dg) = xn0(yr,r,dg);
xd0loop(r,dg) = xd0(yr,r,dg);
rx0loop(r,dg) = rx0(yr,r,dg);
md0loop(r,m,dg) = md0(yr,r,m,dg);
nm0loop(r,m,dg) = nm0(yr,r,m,dg);
dm0loop(r,m,dg) = dm0(yr,r,m,dg);
yh0loop(r,dg) = yh0(yr,r,dg);
cd0loop(r,dg) = cd0(yr,r,dg);
i0loop(r,dg) = i0(yr,r,dg);
g0loop(r,dg) = g0(yr,r,dg);
bopdef0loop(r) = bopdef0(yr,r);
hhadjloop(r) = hhadj(yr,r);
ta(r,dg) = ta0(yr,r,dg);
tm(r,dg) = tm0(yr,r,dg);
netgenloop(r) = netgen(r,yr,'seds');
edloop(r,e,demsec) = ed0(yr,r,e,demsec);
nat_ys(s,g) = ys0nat(yr,s,g);
nat_x(s) = x0nat(yr,s);
nat_m(s) = m0nat(yr,s);
nat_va(s) = va0nat(yr,s);
nat_g(s) = g0nat(yr,s);
nat_i(s) = i0nat(yr,s);
nat_c(s) = cd0nat(yr,s);

$if %matbal% == huber v0("ys0",r,ds,dg) = ys0loop(r,ds,dg);
$if %matbal% == huber v0("id0",r,ds,dg) = id0loop(r,ds,dg);
$if %matbal% == huber nonzero(mat,r,ds,dg) = yes$v0(mat,r,ds,dg);
$if %matbal% == huber zeros(mat,r,ds,dg) = yes$(not v0(mat,r,ds,dg));
$if %matbal% == huber X1.FX(zeros) = 0;
$if %matbal% == huber X2.FX(zeros) = 0;
$if %matbal% == huber X3.FX(zeros) = 0;
$if %matbal% == huber X2.UP(nonzero) = thetab;
$if %matbal% == huber X2.LO(nonzero) = -gammab;
$if %matbal% == huber X3.UP(nonzero) = 1-gammab-1e-5;
$if %matbal% == huber X3.LO(nonzero) = 0;
$if %matbal% == huber X1.L(nonzero) = 0;
$if %matbal% == huber X2.L(nonzero) = 0;
$if %matbal% == huber X3.L(nonzero) = 0;

* Set starting values for balancing routine:

YS.L(r,ds,dg) = ys0loop(r,ds,dg);
ID.L(r,dg,ds) = id0loop(r,dg,ds);
LD.L(r,ds) = ld0loop(r,ds);
KD.L(r,ds) = kd0loop(r,ds);
ARM.L(r,dg) = a0loop(r,dg);
ND.L(r,dg) = nd0loop(r,dg);
DD.L(r,dg) = dd0loop(r,dg);
IMP.L(r,dg) = m0loop(r,dg);
SUP.L(r,dg) = s0loop(r,dg);
XD.L(r,dg) = xd0loop(r,dg);
XN.L(r,dg) = xn0loop(r,dg);
XPT.L(r,dg) = x0loop(r,dg);
RX.L(r,dg) = rx0loop(r,dg);
NM.L(r,m,dg) = nm0loop(r,m,dg);
DM.L(r,m,dg) = dm0loop(r,m,dg);
MARD.L(r,m,dg) = md0loop(r,m,dg);
YH.L(r,dg) = yh0loop(r,dg);
CD.L(r,dg) = cd0loop(r,dg);
INV.L(r,dg) = i0loop(r,dg);
GD.L(r,dg) = g0loop(r,dg);
BOP.L(r) = bopdef0loop(r);

* Impose some zero restrictions:

RX.FX(r,dg)$(rx0loop(r,dg) = 0) = 0;
MARD.FX(r,m,dg)$(md0loop(r,m,dg) = 0) = 0;

* Foreign electricity imports and exports are set to zero subject to SEDS
* data:

XPT.FX(r,'ele_uti')$(x0loop(r,'ele_uti') = 0) = 0;
IMP.FX(r,'ele_uti')$(m0loop(r,'ele_uti') = 0) = 0;
XPT.LO(r,'ele_uti')$(x0loop(r,'ele_uti') > 0) = 0.2 * x0loop(r,'ele_uti');XD.LO(r,dg)$xd0loop(r,dg) = 0.8 * xd0loop(r,dg);
IMP.LO(r,'ele_uti')$(m0loop(r,'ele_uti') > 0) = 0.2 * m0loop(r,'ele_uti');

* Fix electricity imports from the national market for Alaska and Hawaii
* to zero:

ND.FX(r,'ele_uti')$(sameas(r,'HI') or sameas(r,'AK')) = 0;
XN.FX(r,'ele_uti')$(sameas(r,'HI') or sameas(r,'AK')) = 0;

* Provide an allowable range on how SEDS data can shift:

YS.LO(r,ioe,ioe) = 0.8 * ys0loop(r,ioe,ioe);
YS.UP(r,ioe,ioe) = 1.2 * ys0loop(r,ioe,ioe);
MARD.LO(r,m,ioe) = 0.8 * md0loop(r,m,ioe);
MARD.UP(r,m,ioe) = 1.2 * md0loop(r,m,ioe);
CD.LO(r,ioe) = 0.8 * cd0loop(r,ioe);
CD.UP(r,ioe) = 1.2 * cd0loop(r,ioe);

ID.LO(r,dg,ds) = 0.5 * id0loop(r,dg,ds);
ID.UP(r,dg,ds) = inf;
ID.LO(r,ioe,dg) = 0.8 * id0loop(r,ioe,dg);
ID.UP(r,ioe,dg) = 1.2 * id0loop(r,ioe,dg);

* Solve the iteration of the calibration procedure:

$if %matbal% == huber solve regcalib using NLP minimizing OBJ;
$if %matbal% == ls solve regcalib using QCP minimizing OBJ;

abort$(regcalib.modelstat > 1) "Optimal solution not found.";

* Reset parameter values:

ys0(yr,r,ds,dg) = YS.L(r,ds,dg);
id0(yr,r,dg,ds) = ID.L(r,dg,ds);
ld0(yr,r,ds) = LD.L(r,ds);
kd0(yr,r,ds) = KD.L(r,ds);
a0(yr,r,dg) = ARM.L(r,dg);
nd0(yr,r,dg) = ND.L(r,dg);
dd0(yr,r,dg) = DD.L(r,dg);
m0(yr,r,dg) = IMP.L(r,dg);
s0(yr,r,dg) = SUP.L(r,dg);
xd0(yr,r,dg) = XD.L(r,dg);
xn0(yr,r,dg) = XN.L(r,dg);
x0(yr,r,dg) = XPT.L(r,dg);
rx0(yr,r,dg) = RX.L(r,dg);
nm0(yr,r,m,dg) = NM.L(r,m,dg);
dm0(yr,r,m,dg) = DM.L(r,m,dg);
md0(yr,r,m,dg) = MARD.L(r,m,dg);
yh0(yr,r,dg) = YH.L(r,dg);
cd0(yr,r,dg) = CD.L(r,dg);
i0(yr,r,dg) = INV.L(r,dg);
g0(yr,r,dg) = GD.L(r,dg);
bopdef0(yr,r) = BOP.L(r);

* Reset variables boundaries:

RX.LO(r,dg) = 0;
RX.UP(r,dg) = inf;
XPT.LO(r,'ele_uti') = 0;
XPT.UP(r,'ele_uti') = inf;
IMP.LO(r,'ele_uti') = 0;
IMP.UP(r,'ele_uti') = inf;
ND.LO(r,'ele_uti') = 0;
ND.UP(r,'ele_uti') = inf;
XN.LO(r,'ele_uti') = 0;
XN.UP(r,'ele_uti') = inf;
YS.LO(r,ds,dg) = 0;
YS.UP(r,ds,dg) = inf;
MARD.LO(r,m,dg) = 0;
MARD.UP(r,m,dg) = inf;
CD.LO(r,dg) = 0;
CD.UP(r,dg) = inf;
ID.LO(r,dg,ds) = 0;
ID.UP(r,dg,ds) = inf;

);

ys0loop(r,ds,dg) = YS.L(r,ds,dg);
id0loop(r,dg,ds) = ID.L(r,dg,ds);
ld0loop(r,ds) = LD.L(r,ds);
kd0loop(r,ds) = KD.L(r,ds);
a0loop(r,dg) = ARM.L(r,dg);
nd0loop(r,dg) = ND.L(r,dg);
dd0loop(r,dg) = DD.L(r,dg);
m0loop(r,dg) = IMP.L(r,dg);
s0loop(r,dg) = SUP.L(r,dg);
xd0loop(r,dg) = XD.L(r,dg);
xn0loop(r,dg) = XN.L(r,dg);
x0loop(r,dg) = XPT.L(r,dg);
rx0loop(r,dg) = RX.L(r,dg);
nm0loop(r,m,dg) = NM.L(r,m,dg);
dm0loop(r,m,dg) = DM.L(r,m,dg);
md0loop(r,m,dg) = MARD.L(r,m,dg);
yh0loop(r,dg) = YH.L(r,dg);
cd0loop(r,dg) = CD.L(r,dg);
i0loop(r,dg) = INV.L(r,dg);
g0loop(r,dg) = GD.L(r,dg);
bopdef0loop(r) = BOP.L(r);
ta(r,dg) = ta0('%year%',r,dg);
tm(r,dg) = tm0('%year%',r,dg);
c0loop(r) = sum(dg, cd0loop(r,dg));

* -------------------------------------------------------------------
* Write a report on the differences in the dataset relative to
* the core blueNOTE output:
* -------------------------------------------------------------------

* I.e. change in data for energy sectors only, and then an aggregate change in
* data.

dataconschk(r,ds,'ys0','new') = sum(dg, ys0loop(r,ds,dg));
dataconschk(r,dg,'id0','new') = sum(ds, id0loop(r,dg,ds));
dataconschk(r,ds,'va0','new') = ld0loop(r,ds) + kd0loop(r,ds);

dataconschk(r,dg,'i0','new') = i0loop(r,dg);
dataconschk(r,dg,'g0','new') = g0loop(r,dg);
dataconschk(r,dg,'cd0','new') = cd0loop(r,dg);
dataconschk(r,dg,'yh0','new') = yh0loop(r,dg);
dataconschk(r,'total','hhadj','new') = hhadj_('%year%',r);
dataconschk(r,'total','bop','new') = bopdef0loop(r);

dataconschk(r,dg,'s0','new') = s0loop(r,dg);
dataconschk(r,dg,'xd0','new') = xd0loop(r,dg);
dataconschk(r,dg,'xn0','new') = xn0loop(r,dg);
dataconschk(r,dg,'x0','new') = x0loop(r,dg);
dataconschk(r,dg,'rx0','new') = rx0loop(r,dg);
dataconschk(r,dg,'a0','new') = a0loop(r,dg);
dataconschk(r,dg,'nd0','new') = nd0loop(r,dg);
dataconschk(r,dg,'dd0','new') = dd0loop(r,dg);
dataconschk(r,dg,'m0','new') = m0loop(r,dg);

dataconschk(r,dg,'md0','new') = sum(m, md0loop(r,m,dg));
dataconschk(r,dg,'nm0','new') = sum(m, nm0loop(r,m,dg));
dataconschk(r,dg,'dm0','new') = sum(m, dm0loop(r,m,dg));

alias(u,k,*);

set	es(*)	Energy sectors;

es(ioe) = yes;
es('oil_oil') = yes;

parameter	pctchg	Percent Change in the data;

* All sectors for each parameter:
pctchg(u,'all')$sum((r,k), dataconschk(r,k,u,'old')) = 100 * (sum((r,k), dataconschk(r,k,u,'new')) / sum((r,k), dataconschk(r,k,u,'old')) - 1);

* All sectors total:
pctchg('total','all')$sum((r,k,u), dataconschk(r,k,u,'old')) = 100 * (sum((r,k,u), dataconschk(r,k,u,'new')) / sum((r,k,u), dataconschk(r,k,u,'old')) - 1);

* Energy sectors for each parameter:
pctchg(u,'eng')$sum((r,es), dataconschk(r,es,u,'old')) = 100 * (sum((r,es), dataconschk(r,es,u,'new')) / sum((r,es), dataconschk(r,es,u,'old')) - 1);

* Energy sectors total:
pctchg('total','eng') = 100 * (sum((r,es,u), dataconschk(r,es,u,'new')) / sum((r,es,u), dataconschk(r,es,u,'old')) - 1);

execute_unload 'temp\enforcechg.gdx' pctchg;
execute 'gdxxrw.exe i=temp\enforcechg.gdx o=temp\enforcechg.xlsx par=pctchg rng=pctchg!A2 cdim=0'

* -------------------------------------------------------------------
* Output regionalized dataset calibrated to %calibto%:
* -------------------------------------------------------------------

execute_unload '%dsdir%blueNOTE_%sectors%_%year%%calibto%.gdx' 

* Sets:
 
r,ds=s,m,

* Production data: 

ys0loop=ys0,ld0loop=ld0,kd0loop=kd0,id0loop=id0,

* Consumption data:

yh0loop=yh0,c0loop=c0,cd0loop=cd0,i0loop=i0,g0loop=g0,bopdef0loop=bopdef0,hhadjloop=hhadj,

* Trade data:

s0loop=s0,xd0loop=xd0,xn0loop=xn0,x0loop=x0,rx0loop=rx0,a0loop=a0,
nd0loop=nd0,dd0loop=dd0,m0loop=m0,ta=ta0,tm=tm0,

* Margins:

md0loop=md0,nm0loop=nm0,dm0loop=dm0;