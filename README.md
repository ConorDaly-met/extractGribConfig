# extractGribConfig

Contains the configuration files required for the **extractGrib** software

## Introduction

**extractGrib** deconstructs gl namelists and builds them up again.
**extractGribConfig** contains the files necessary to define the namelists.

### Author
Conor Daly
<conor.daly@met.ie>

Met Éireann

### Installation

The default installation path is ```$HOME/extractGribConfig/$EXP```

but on ecgate it needs to be ```/hpc$HOME/extractGribConfig/$EXP```

- `git clone` this repo
-       ```
        $~> mkdir build
        $~> cd build
        $~> (
        $~>   export EXP=harmonie-experiment-name
        $~>   cmake ..
        $~> )
        $~>     or
        $~> (
        $~>   cmake .. -DCMAKE_INSTALL_PREFIX=/path/to/installation/
        $~> )
        $~> make
        $~> make install
        ```
- this will create your local file structure:
	```
	share/griblists/cccc/
	share/namelist_inc/cccc/
	share/paramlists/cccc/
	```
 	under /path/to/installation/$EXP

- [Populate](#setup) with parameter lists, sub-domains/projections, griblists
- run makeparamlists.sh script to convert parameter lists to namelist fragments.
    - ```/path/to/installation/bin/makeparamlists.sh```
- Create environment variable USERAREA pointing to your `share/griblists` (Default is `$HOME/extractGribConfig/$EXP/share/griblists`)

#### Testing

Your installation is now ready for test.  

- Create and cd to your extractGribFiles location 
- Run the makerunex.sh script and follow instructions
    - ```/path/to/installation/bin/makerunex.sh```
      - if you do not set EXP, it will derive the value from the installation path.
      - If you wish to test against a different harmonie experiment, set EXP appropriately.

### Workflow

#### Setup
1. Generate your [Parameter lists](#parameter-lists)
1. Generate your [Parameter namelists](#parameter-namelists)
1. Generate your [Sub-domains](#sub-domains-and-thinning)
1. Generate your [Griblists](#griblists)

#### Routine
1. [Extract](#extraction) data

### Parameter lists

- `${bindir}/share/paramlists/param_source.cfg` knows where the data is to be found

- You need to use [`${bindir}/bin/grib_paramlist.sh`](#grib_paramlistsh) to extract a list of parameters from an existing grib file
- Or you can create one by hand.
- These should be saved as some `share/paramlists/cccc/<param>.list` or `share/paramlists/<param>.list`

### Parameter namelists

- Parameter namelist fragments are stored in `share/namelist_inc/cccc/30-<paramlist>_P-b.inc` or `share/namelist_inc/30-<paramlist>_P-b.inc`

- You need to use [`${bindir}/bin/do_paramset.sh`](#do_paramsetsh) to create the fragments
- Or you can use [`${bindir}/bin/read_paramlist.sh`](#read_paramlistsh) to see an individual fragment

### Sub-domains and Thinning

- Subdomain namelist fragments are stored in `share/namelist_inc/cccc/20-<proj>.inc` or `share/namelist_inc/20-<proj>.inc`

- Use [`${bindir}/bin/make_subdomain.sh`](#make_subdomainsh) to construct a sub-domain/thinned namelist fragment.
- Or you can use [`${bindir}/bin/grib_proj.sh`](#grib_projsh) to extract the fragment from an existing grib file

### Griblists

- Griblists define the set of namelist fragments to be used for a specific product
- Griblists are stored in `share/griblists/cccc/control.list`, `share/griblists/cccc/standing.list` and `share/griblists/cccc/user.list`
- control.list is used only for extraction from the control member.  standing.list and user.list are extracted from all ensemble members including control
- [Samples](#griblist-samples) are in `${bindir}/share/griblists/`

### Extraction

- `${bindir}/bin/extract_fa.sh` does the actual namelist generation and extraction of data

- `${bindir}/bin/extractGrib` performs the functionality of Makegrib if called with the correct switches.

### Usage

	Usage:	bin/extractGrib [-a <USERAREA>] [-f <FCST/PATH>] [-m] [-t <type> [-t <type>]] [-h] [-i] [-k] [-n]
		bin/extractGrib -h

	Extracts requested dataset(s) from Harmonie FA outputs using user-supplied request lists.

	-a <USERAREA> 		Sets the source area for user lists (currently: $HOME/hm_home/extractGrib/share/griblists)
        -d <DTG>		Sets the DateTimeGroup for the forecast       (currently: 2021061006)
        -dm <DOMAIN>		Sets the Domain name for the forecast         (currently: IRELAND25_090)
        -em <ENSMBR>		Sets the Ensemble Member for the forecast     (currently: -1)
        -en <NUMMBR>		Sets the Number of forecasts in the ensemble  (currently: 16)
        -ex <EXPT>		Sets the Experiment name for the forecast     (currently: HARM)
        -ez <EZONE>		Sets the boundary zone to remove from his/sfx (currently: 11)
	-f <FCST/PATH> 		Sets the input path for the forecast (currently: .)
	-m			Sets a member path of the form mbrXXX to be appended to <FCST/PATH>
        -s <STEP>               Sets the Step for the forecast                (currently: 3)
	-t <type> 		Sets the input file type(s) for the forecast (currently: fp his)
					 Available types are	fp  - fullpos
								his - history
								sfx - SURFEX

	-i		Fetch the forecast files directly from the I/O servers
	-k		Do not delete the namelist
	-n		Dry-run.  Does not execute the gl run, just makes and displays the namelist

	-h		Show this help
        -h manual           Displays the README.md file

	Environment Variables:

	extractGrib expects the following environment variables to be set:
                It will accept them from the commandline also.

		Variable	Current Value	Comment
		EXP		cca_dini25a_l90_arome
						Experiment name for the input forecast.  This defines the path to config-sh/
		FCSTPATH	.
						Path to the input forecast
		EXPT		HARM	
						The experiment name
		DOMAIN		IRELAND25_090
						The forecast domain name
		EZONE		11
						The boundary zone to remove from his/sfx files

		DTG		2021062106	
						The date/time group for the forecast
		STEP		-1
						The forecast step
		ENSMBR		10
						The ensemble member
		NUMMBR		16
						The number of forecasts in the ensemble


#### grib_paramlist.sh

	Usage:	bin/grib_paramlist.sh [-g <N>] </path/to/grib.file> [</path/to/grib.file> [</path/to/grib.file>]]
		bin/grib_paramlist.sh -h

	Extracts shortName,typeOfLevel,stepType,level from GRIB and translates to gl namelist
	
        -g <N>  Use grib edition <N> 
                1:   Extract "indicatorOfParameter,indicatorOfTypeOfLevel,timeRangeIndicator,level"
                2:   Extract "shortName,typeOfLevel,stepType,level"

	-h	Show this help

Produces output of the form:

	#
	#/data/cdaly/cdtemp/bullnwpdata/mbr000/eidb/fc2021062106+012grib2_pp
	#14:of:14:messages:in:/data/cdaly/cdtemp/bullnwpdata/mbr000/eidb/fc2021062106+012grib2_pp
	#14:of:14:total:messages:in:1:files
	shortName:typeOfLevel:tri:level
	ct:entireAtmosphere:0:0
	cwat_cond:entireAtmosphere:0:0
	icei2:heightAboveGround:0:1524
	icei2:heightAboveGround:0:305
	icei2:heightAboveGround:0:610
	icei2:heightAboveGround:0:914
	lgt:entireAtmosphere:0:0
	mld:heightAboveGround:0:0
	prtp:heightAboveGround:0:0
	pscw:heightAboveGround:0:0
	pstbc:heightAboveGround:0:0
	pstb:heightAboveGround:0:0
	tcc:heightAboveGround:0:2
	vis:heightAboveGround:0:0

or of the form:

	#14:of:14:total:messages:in:1:files
	indicatorOfParameter:indicatorOfTypeOfLevel:tri:level
	61:heightAboveGround:0:4
	17:heightAboveGround:0:0

This output should be saved as the appropriate <param.list>.

Entries may be consolidated by merging the 'level' column with comma separated values and/or ranges thus

	icei2:heightAboveGround:0:305,610,914,1524

which will translate to four 'icei2' entries or

	w:hybrid:0:1-65

which will translate to 65 'w, hybrid' entries.  

A 'level' range of '-1' is passed through to gl unchanged, gl will expand this to 'all available'.

#### make_subdomain.sh

	Usage:	bin/make_subdomain.sh [-c <comment>] [(-r <resolution> | -rt <latres> -rn <lonres>)]
		(-sw <LATSOUTH>,<LONWEST> | -np <NLAT>,<NLON> | -lc <CLAT>,<CLON> | -ne <LATNORTH>,<LATEAST>) 

		bin/make_subdomain.sh -l <LAT>,<LON> [-c <comment>]

	Creates a gl namelist for the extraction of subdomain or point data
	
	-c <comment>	Adds a comment to the output

	############ Point extraction #####################
	-l <LAT>,<LON>	Specifies the point to be extracted.
			Output will be a csv file.

	############ Subdomain extraction #####################
	-sw <LAT>,<LON>		Coordinates of SouthWest corner
	-np <NLAT>,<NLON>	Number of grid points 
	-lc <LAT>,<LON>		Coordinates of Centre point
	-ne <LAT>,<LON>		Coordinates of NorthEast corner

	-r  <resolution>		Size of grid box in metres.  (Currently:  x )
	-rt <Latitude  resolution>	N-S length of gridbox in metres (Currently: )
	-rn <Longitude resolution>	W-E length of gridbox in metres (Currently: )

	The subdomain is specified by two of:
		The SouthWest corner,
		The number of grid points,
		The centre point,
		The NorthEast corner.
	
		The default gridbox size is  x 

		Output will be a grib subdomain
	

Produces output of the form:


	# Comment line
	  outgeo%dlon = 2500.
	  outgeo%dlat = 2500.
	  outgeo%gridtype = 'lambert'
	  outgeo%projlat = 53.5
	  outgeo%projlat2 = 53.5
	  outgeo%south = 49.8834
	  outgeo%west = -10.961
	  outgeo%projlon = 5.
	  outgeo%nlon = 236
	  outgeo%nlat = 271

The values:
- dlon,dlat specify the spatial resolution in metres
- nlon,nlat specify the number of gridpoints
- south,west specify the SW corner of the (sub-)domain.

This output should be saved to `share/namelist_inc/cccc/20-<proj>.inc` or `share/namelist_inc/20-<proj>.inc` where 'proj' is the name of the projection to be used in a [griblist](#griblists)

#### grib_proj.sh

	Usage:	bin/grib_proj.sh </path/to/grib.file>
		bin/grib_proj.sh -h

	Extracts projection information from GRIB and translates to gl namelist
	
	-h	Show this help

Produces output of the form:


	# /data/cdaly/cdtemp/bullnwpdata/mbr000/eidb/fc2021062106+012grib2_mlIoI
	  outgeo%dlon = 2500.
	  outgeo%dlat = 2500.
	  outgeo%gridtype = 'lambert'
	  outgeo%projlat = 53.5
	  outgeo%projlat2 = 53.5
	  outgeo%south = 49.8834
	  outgeo%west = -10.961
	  outgeo%projlon = 5.
	  outgeo%nlon = 236
	  outgeo%nlat = 271


or

	# /data/cdaly/cdtemp/bullnwpdata/mbr000/knmi/fc2021062106+010grib2_en_10k
	  outgeo%dlon = 10000.
	  outgeo%dlat = 10000.
	  outgeo%gridtype = 'lambert'
	  outgeo%projlat = 53.5
	  outgeo%projlat2 = 53.5
	  outgeo%south = 46.834
	  outgeo%west = -14.609
	  outgeo%projlon = 5.
	  outgeo%nlon = 129
	  outgeo%nlat = 145

The values:
- dlon,dlat specify the spatial resolution in metres
- nlon,nlat specify the number of gridpoints
- south,west specify the SW corner of the (sub-)domain.

This output should be saved to `share/namelist_inc/cccc/20-<proj>.inc` or `share/namelist_inc/20-<proj>.inc` where 'proj' is the name of the projection to be used in a [griblist](#griblists)

#### read_paramlist.sh

	Usage:	bin/read_paramlist.sh (-d|p|b) (-I|P) <path/to/param.list>
		bin/read_paramlist.sh -h

	Read param.list and write out a gl namelist stanza for the contained parameters.
        If param.list contains the header: indicatorOfParameter the gl namelist stanza will use readkey%pid
                                           Otherwise the gl namelist stanza will use readkey%shortname

	-d	Diagnostic    params (readkey%...)
	-p	Postprocessed params (pppkey%...)
	-b	Diag + Post_p params (pppkey%...)

	-I	ICMSHHARM... is the source FA file
	-P	PFHARM... is the source FA file
	-B      Both ICMSHHARM... and PFHARM... are the source FA files

	-h	Show this help

produces output of the form:

	bin/read_paramlist.sh -b -P /data/cdaly/cdtemp/bullnwpdata/share/paramlists/eidb/pp.list 
	readkey%shortname='tcc',
	readkey%levtype='heightAboveGround',
	readkey%level=2,
	readkey%tri=0,

or:
	readkey%pid=71,
	readkey%levtype='heightAboveGround',
	readkey%level=2,
	readkey%tri=0,
or:

	bin/read_paramlist.sh -b -B /data/cdaly/cdtemp/bullnwpdata/share/paramlists/eidb/pp.list 
	readkey%shortname='cb','ct','cwat_cond','icei2','icei2','icei2','icei2','lgt','mld','prtp','pscw','pstbc','pstb','tcc','vis',
	readkey%levtype='entireAtmosphere','entireAtmosphere','entireAtmosphere','heightAboveGround','heightAboveGround','heightAboveGround','heightAboveGround','entireAtmosphere','heightAboveGround','heightAboveGround','heightAboveGround','heightAboveGround','heightAboveGround','heightAboveGround','heightAboveGround',
	readkey%level=0,0,0,305,610,914,1524,0,0,0,0,0,0,2,0,
	readkey%tri=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,

#### do_paramset.sh

	Usage:	bin/do_paramset.sh [-b] -o <path/to/namelists/> [-n <namelist_name>] <path/to/parameter.list> 
		bin/do_paramset.sh -h

	Reads <path/to/parameter.list> and outputs appropriate namelist entries for
		each of 'direct' and 'postprocessed' data from ICMSHHARM and PFHARM forecast files.

	-b Write both Diagnostic and Postprocessed params to a single namelist

	-o Output path.
		Files will be written of the form '30-parameter_P-d.inc' where 'parameter' is the
		name of the <parameter.list> with the '.list' extension removed.

	-n Namelist name.
		This will replace the 'parameter' element of the output filename.

	-h Show this help

This runs `${bindir}/bin/read_paramlist.sh` with the various switches necessary and saves output to `<path/to/namelists>/30-<param>_X-n.inc` where:

- X is one of B,I,P meaning: B - both, I - his, P - fullpos
- n is one of b,d,p meaning: b - both, d - direct, p - postprocessed

Typical usage is:

	bin/do_paramset.sh -b -o share/namelist_inc/cccc/ share/paramlists/cccc/<param>.list
	bin/do_paramset.sh -b -o share/namelist_inc/ share/paramlists/<param>.list

#### Griblist Samples

	# Standing orders list for knmi files
	#
	# This file may not contain blank lines
	#
	# MEMORY keyword postprocesses data into memory.  This is used later to extract post-processed data to file.
	# A MEMORY keyword must precede the first extraction of postprocessed data to file
	#MEMORY		-C centre	-T	-p Parameter list
	# -T implies store to memory.
	#
	# A grib_extension is used to generate a file of the form: fcYYYYMMDDHH+SSS.grib_extension
	# Parameter list and Projection/sub-domain entries must exist in share/namelist_inc/centre/
	#grib_extension     -C centre -g grib1|2 -k packingType  -p Parameter list -r Projection|sub-domain
	MEMORY       -C knmi -T             -p en_B-p
	grib2_enIoI  -C knmi -g 2 -k ccsds  -p en_B-b -r IofIE
	MEMORY       -C knmi -T             -p en_B-p
	grib2_en_10k -C knmi -g 2 -k ccsds  -p en_B-b -r IRELAND25-10k

In the sample above, the following steps occur:

1. Input datafiles are read into memory

2. The [parameter](#parameter-lists) file `share/namelist_inc/knmi/30-en_B-p.inc` is used to to generate a `pppkey%...` namelist to be stored in memory 

	MEMORY       -C knmi -T             -p en_B-p

	If the file `share/namelist_inc/knmi/30-en_B-p.inc` does not exist the file `share/namelist_inc/30-en_B-p.inc` will be used if it exists. 
	This applies to parameter files and to projection files.

3. The [parameter](#parameter-lists) file `share/namelist_inc/knmi/30-en_B-b.inc` is used to to generate a `readkey%...` namelist to be reprojected using [projection](#sub-domain-and-thinning) file `share/namelist_inc/knmi/20-IofIE.inc` (Island of Ireland subdomain at standard model resolution) and written as 'grib2' using packingType 'ccsds' to output file: `knmi/fcYYYYMMDDHH+SSSgrib2_enIoI`

	grib2_enIoI  -C knmi -g 2 -k ccsds  -p en_B-b -r IofIE

4. The [parameter](#parameter-lists) file `share/namelist_inc/knmi/30-en_B-p.inc` is used to to generate a `pppkey%...` namelist to be stored in memory 

	MEMORY       -C knmi -T             -p en_B-p

5. The [parameter](#parameter-lists) file `share/namelist_inc/knmi/30-en_B-b.inc` is used to to generate a `readkey%...` namelist to be reprojected using [projection](#sub-domain-and-thinning) file `share/namelist_inc/knmi/20-IRELAND25-10k.inc` (full domain @10km resolution) and written as 'grib2' using packingType 'ccsds' to output file: `knmi/fcYYYYMMDDHH+SSSgrib2_enIoI`

	grib2_en_10k -C knmi -g 2 -k ccsds  -p en_B-b -r IRELAND25-10k

6. Finally, the various `pppkey%...` stanzas are merged into one to avoid unnecessary duplication of post-processing.
