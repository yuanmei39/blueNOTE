$title	Read the US Input-Output Summary Tables

* -------------------------------------------------------------------
* 	Read in all provided years of data:
* -------------------------------------------------------------------

$onecho >temp\gdxxrw.rsp
par=use1997 rng=1997!a6 rdim=1 cdim=1
par=use1998 rng=1998!a6 rdim=1 cdim=1
par=use1999 rng=1999!a6 rdim=1 cdim=1
par=use2000 rng=2000!a6 rdim=1 cdim=1
par=use2001 rng=2001!a6 rdim=1 cdim=1
par=use2002 rng=2002!a6 rdim=1 cdim=1
par=use2003 rng=2003!a6 rdim=1 cdim=1
par=use2004 rng=2004!a6 rdim=1 cdim=1
par=use2005 rng=2005!a6 rdim=1 cdim=1
par=use2006 rng=2006!a6 rdim=1 cdim=1
par=use2007 rng=2007!a6 rdim=1 cdim=1
par=use2008 rng=2008!a6 rdim=1 cdim=1
par=use2009 rng=2009!a6 rdim=1 cdim=1
par=use2010 rng=2010!a6 rdim=1 cdim=1
par=use2011 rng=2011!a6 rdim=1 cdim=1
par=use2012 rng=2012!a6 rdim=1 cdim=1
par=use2013 rng=2013!a6 rdim=1 cdim=1
par=use2014 rng=2014!a6 rdim=1 cdim=1
par=use2015 rng=2015!a6 rdim=1 cdim=1
$offecho

* 	Note: GAMS will truncate some of the set indices due to character
* 	length.

$call gdxxrw i="../Data/BEA/IO/Use_SupplyUseFramework_1997-2015_Summary.xlsx" o="temp/gdx/usetables_71sectors.gdx" @temp\gdxxrw.rsp

*	Now pull the data with the labels:

$onecho >temp\gdxxrw.rsp
par=supply1997 rng=1997!a6 rdim=1 cdim=1
par=supply1998 rng=1998!a6 rdim=1 cdim=1
par=supply1999 rng=1999!a6 rdim=1 cdim=1
par=supply2000 rng=2000!a6 rdim=1 cdim=1
par=supply2001 rng=2001!a6 rdim=1 cdim=1
par=supply2002 rng=2002!a6 rdim=1 cdim=1
par=supply2003 rng=2003!a6 rdim=1 cdim=1
par=supply2004 rng=2004!a6 rdim=1 cdim=1
par=supply2005 rng=2005!a6 rdim=1 cdim=1
par=supply2006 rng=2006!a6 rdim=1 cdim=1
par=supply2007 rng=2007!a6 rdim=1 cdim=1
par=supply2008 rng=2008!a6 rdim=1 cdim=1
par=supply2009 rng=2009!a6 rdim=1 cdim=1
par=supply2010 rng=2010!a6 rdim=1 cdim=1
par=supply2011 rng=2011!a6 rdim=1 cdim=1
par=supply2012 rng=2012!a6 rdim=1 cdim=1
par=supply2013 rng=2013!a6 rdim=1 cdim=1
par=supply2014 rng=2014!a6 rdim=1 cdim=1
par=supply2015 rng=2015!a6 rdim=1 cdim=1
$offecho

$call gdxxrw i="../Data/BEA/IO/Supply_1997-2015_Summary.xlsx" o="temp/gdx/supplytables_71sectors.gdx" @temp\gdxxrw.rsp

set	iruse(*)	Rows labels in the use table,
	jcuse(*)	Column labels in the use table,
	irsupply(*)	Row labels in the supply table,
	jcsupply(*)	Column labels in the supply table;

alias (ir,jc,*);

parameter	use1997(ir,jc),
		use1998(ir,jc),
		use1999(ir,jc),
		use2000(ir,jc),
		use2001(ir,jc),
		use2002(ir,jc),
		use2003(ir,jc),
		use2004(ir,jc),
		use2005(ir,jc),
		use2006(ir,jc),
		use2007(ir,jc),
		use2008(ir,jc),
		use2009(ir,jc),
		use2010(ir,jc),
		use2011(ir,jc),
		use2012(ir,jc),
		use2013(ir,jc),
		use2014(ir,jc),
		use2015(ir,jc);

$gdxin 'temp/gdx/usetables_71sectors.gdx'
$loaddc use1997 use1998 use1999 use2000 use2001 use2002
$loaddc use2003 use2004 use2005 use2006 use2007 use2008 use2009
$loaddc use2010 use2011 use2012 use2013 use2014 use2015

parameter	supply1997(ir,jc),
		supply1998(ir,jc),
		supply1999(ir,jc),
		supply2000(ir,jc),
		supply2001(ir,jc),
		supply2002(ir,jc),
		supply2003(ir,jc),
		supply2004(ir,jc),
		supply2005(ir,jc),
		supply2006(ir,jc),
		supply2007(ir,jc),
		supply2008(ir,jc),
		supply2009(ir,jc),
		supply2010(ir,jc),
		supply2011(ir,jc),
		supply2012(ir,jc),
		supply2013(ir,jc),
		supply2014(ir,jc),
		supply2015(ir,jc);

$gdxin 'temp/gdx/supplytables_71sectors.gdx'
$loaddc supply1997 supply1998 supply1999 supply2000 supply2001 supply2002
$loaddc supply2003 supply2004 supply2005 supply2006 supply2007 supply2008 supply2009
$loaddc supply2010 supply2011 supply2012 supply2013 supply2014 supply2015

* -------------------------------------------------------------------
* 	Concatenate years of data into a single parameter:
* -------------------------------------------------------------------

set	yr 	Years of data
		/1997*2015/;

parameter	use(yr,ir,jc)	Annual use matrices;

use("1997",ir,jc) = use1997(ir,jc);
use("1998",ir,jc) = use1998(ir,jc);
use("1999",ir,jc) = use1999(ir,jc);
use("2000",ir,jc) = use2000(ir,jc);
use("2001",ir,jc) = use2001(ir,jc);
use("2002",ir,jc) = use2002(ir,jc);
use("2003",ir,jc) = use2003(ir,jc);
use("2004",ir,jc) = use2004(ir,jc);
use("2005",ir,jc) = use2005(ir,jc);
use("2006",ir,jc) = use2006(ir,jc);
use("2007",ir,jc) = use2007(ir,jc);
use("2008",ir,jc) = use2008(ir,jc);
use("2009",ir,jc) = use2009(ir,jc);
use("2010",ir,jc) = use2010(ir,jc);
use("2011",ir,jc) = use2011(ir,jc);
use("2012",ir,jc) = use2012(ir,jc);
use("2013",ir,jc) = use2013(ir,jc);
use("2014",ir,jc) = use2014(ir,jc);
use('2015',ir,jc) = use2015(ir,jc);

* 	Identify which row and column indices are used in the use tables:

loop((yr,ir,jc)$use(yr,ir,jc),
	iruse(ir) = yes;
	jcuse(jc) = yes; );

parameter	supply(yr,ir,jc)	Annual supply matrices;

supply("1997",ir,jc) = supply1997(ir,jc);
supply("1998",ir,jc) = supply1998(ir,jc);
supply("1999",ir,jc) = supply1999(ir,jc);
supply("2000",ir,jc) = supply2000(ir,jc);
supply("2001",ir,jc) = supply2001(ir,jc);
supply("2002",ir,jc) = supply2002(ir,jc);
supply("2003",ir,jc) = supply2003(ir,jc);
supply("2004",ir,jc) = supply2004(ir,jc);
supply("2005",ir,jc) = supply2005(ir,jc);
supply("2006",ir,jc) = supply2006(ir,jc);
supply("2007",ir,jc) = supply2007(ir,jc);
supply("2008",ir,jc) = supply2008(ir,jc);
supply("2009",ir,jc) = supply2009(ir,jc);
supply("2010",ir,jc) = supply2010(ir,jc);
supply("2011",ir,jc) = supply2011(ir,jc);
supply("2012",ir,jc) = supply2012(ir,jc);
supply("2013",ir,jc) = supply2013(ir,jc);
supply("2014",ir,jc) = supply2014(ir,jc);
supply("2015",ir,jc) = supply2015(ir,jc);

* 	Identify which row and column indices are used in the supply tables:

loop((yr,ir,jc)$supply(yr,ir,jc),
	irsupply(ir) = yes;
	jcsupply(jc) = yes; );

* -------------------------------------------------------------------
* 	Output raw input-output data:
* -------------------------------------------------------------------

execute_unload 'temp/gdx/national_iotable_raw.gdx', use, supply, iruse, irsupply, jcuse, jcsupply;