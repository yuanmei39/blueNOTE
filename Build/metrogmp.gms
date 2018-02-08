$title GAMS program for hacking the Metro GMP dataset

* In order to convert the raw Metro dataset to a gams readable format, I use
* stata. See metrogdp.do in the data directory.

* -------------------------------------------------------------------------
* 	Read in the data:
* -------------------------------------------------------------------------

* Data for 2015 was incomplete. First year of data was in 2001.

set	yr /2001*2014/;

set	r	Regions /
$include defines\msagmp.set
/,
	sec	Industry list /
$include defines\sectorsgmp.set
/,
	com	Components of GDP /
$include defines\componentgmp.set
/;

parameter	metrogmp_(r,yr,com,sec)	MSA level annual GDP;

$call 'gdxxrw.exe i=..\Data\BEA\GDP\Metro\metrogmp.xlsx o=gdx\metrogmp.gdx par=metrogmp_ rng=metrogmp! rdim=4 cdim=0'
$gdxin 'gdx\metrogmp.gdx'
$loaddc metrogmp_

* -------------------------------------------------------------------------
* 	Map indices to match national files and eliminate numeric sets:
* -------------------------------------------------------------------------

set 	gdpcat 	GDP category names/
		gdp	"Gross domestic product (GDP) by metropolitan area"
		qty	"Quantity indexes for real GDP by metropolitan area"
		rgdp	"Real GDP by metropolitan area" /
	gdpmap(gdpcat,com)	Mapping between category names
				/ gdp.200, qty.800, rgdp.900 /;

set	i	Goods and sectors /
$include 'defines\goodssectors.set'
/,
	mapseci(sec,i)	Mapping between state industry ids /
$include 'defines\gspsecmap.map'
/;

* Note that in the mapping, aggregate categories in the GSP dataset are
* removed. Also, the used and other sectors don't have any mapping to the
* state files. In cases other than used and other, the national files have
* more detail. In cases where multiple sectors are mapped to the state gdp
* estimates, the same profile of GDP will be used.

parameter 	metrogmp(r,yr,gdpcat,i)	Mapped MSA level annual GDP;
 
loop((mapseci(sec,i),gdpmap(gdpcat,com)),
	metrogmp(r,yr,gdpcat,i) = metrogmp_(r,yr,com,sec););

display metrogmp;
$exit

execute_unload 'gdx\mappedmetrogmp.gdx',metrogmp,yr,r,i,sec,com,gdpcat;