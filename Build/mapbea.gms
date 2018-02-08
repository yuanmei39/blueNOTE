$title	Read the IO Table and Generate IO Data

* -------------------------------------------------------------------
* 	Read in dataset:
* -------------------------------------------------------------------

sets  iruse(*), irsupply(*), jcuse(*), jcsupply(*);

$gdxin 'temp\gdx\national_iotable_raw.gdx'

$loaddc iruse irsupply jcuse jcsupply

set 	yr 	Years in the dataset
		/1997*2015/;

parameter	use_(yr,iruse,jcuse)		Annual use matrices,
		supply_(yr,irsupply,jcsupply)	Annual supply matrices;

$loaddc use_=use supply_=supply

* -------------------------------------------------------------------
* 	Translate text identifiers to NAICS code labels.
* -------------------------------------------------------------------

set 	ir_use		Numeric identifiers for use table rows /
$include 'defines\naics_rowuse.set'
/,
 	jc_use		Numeric identifiers for use table columns /
$include 'defines\naics_coluse.set'
/,
 	ir_supply	Numeric identifiers for supply table rows /
$include 'defines\naics_rowsupply.set'
/,
 	jc_supply	Numeric identifiers for supply table columns /
$include 'defines\naics_colsupply.set'
/,
 	ir_usemap(ir_use,iruse) 	Mapping to numeric identifiers /
$include 'defines\naics_rowuse.map'
/,
	jc_usemap(jc_use,jcuse)		Mapping to numeric identifiers /
$include 'defines\naics_coluse.map'
/,
	ir_supplymap(ir_supply,irsupply)	Mapping to numeric identifiers /
$include 'defines\naics_rowsupply.map'
/,
	jc_supplymap(jc_supply,jcsupply) 	Mapping to numeric identifiers /
$include 'defines\naics_colsupply.map'
/;

parameter	use(yr,ir_use,jc_use)		Mapped annual use tables,
		supply(yr,ir_supply,jc_supply)	Mapped annual supply tables;

loop((ir_usemap(ir_use,iruse),jc_usemap(jc_use,jcuse)),
	use(yr,ir_use,jc_use) = use_(yr,iruse,jcuse));

loop((ir_supplymap(ir_supply,irsupply),jc_supplymap(jc_supply,jcsupply)),
	supply(yr,ir_supply,jc_supply) = supply_(yr,irsupply,jcsupply));

* -------------------------------------------------------------------
* 	Output mapped input-output data:
* -------------------------------------------------------------------

execute_unload 'temp\gdx\national_mapiotable.gdx',use,supply,ir_use,ir_supply,jc_use,jc_supply;
