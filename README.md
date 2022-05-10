# LogToGpx

LogToGpx is a simple tool to convert log data of a certain syntax into broadwide `.gpx` format. This tool was created for data analysis of tram line gps collection, to easily convert collected data into a more usable format.

## Usage

Several gem dependencies are required to be installed before usage, see [setup](#setup) before use.

To use the tool, simply run the `main.rb` file in command line (providing you have ruby installed), with `.log` file paths in arguments, like so:

```bash
ruby lib/main.rb exampleFile1.log foo/exampleFile2.log
```

The program will convert files from file paths in arguments, and write `.gpx` file, with the same name in the specified destination. 

## Log file syntax

Files with `.log` extension this converter uses need to have a strict line format specified bellow, where each line represents one track point. [Example file](./data/example.log) with such format is provided for guideline. 

```
2021-04-17 20:18:10,041 - INFO - ;LAT;481580718;LON;171071553;HMSL;175024;GSPEED;1;CRS;0;HACC;1675
```

Values are delimited by `;`, key followed by value:
 - Date and time (string " - INFO - " is ignored)
 - LAT - latitude coordinates
 - LON  - longitude coordinates
 - HMLS - height meters above sea level number (in milimetres)
 - GSPEED - current speed in cm/s
 - CRS  - course
 - HACC - horizontal accuracy in micrometers

## Output file syntax

Script produces a `.gpx` format files, according to the [official GPX 1.0 implementation specifications](https://www.topografix.com/gpx_manual.asp), enhanced with several more optional trackpoint elements (needed for transfer of tram speed as `<vtram>` and `<hacc>` for horizontal accuracy). Since the added elements are optional, they should not interfere with other software.


## Speed offset calculation utility

A utility script `offset.rb` is also provided for a quick calculation of speed offset and horizontal accuracy in a converted `.gpx` file. To run this script, provide a `.gpx` file path in arguments, similarly to `main.rb` script. The script will extract all speed and accuracy data from all files provided in the scripts aruments, and print out the average speed offset, together with max and min horizontal accuracy. A reccomended use is with a set of `.gpx` files, for calculations across several files. To do this, use `*.gpx` as an argument.

Run the `offset.rb` script with:

```bash
ruby lib/offset.rb exampleFile1.gpx foo/*.gpx
```

# Setup

This script uses several gems, that are needed for execution. These gems are listed in `Gemfile`. Install these gems before using the script (sudo permissions might be needed):

```bash
# install bundler
gem install bundler

# use bundler to install gems in Gemfile
bundle install
```
