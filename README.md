# LogToPgx

LogToPgx is a simple tool to convert log data of a certain syntax into broadwide `.pgx` format. This tool was created for data analysis of tram line gps collection, to easily convert collected data into a more usable format.

## Usage

To use the tool, simply run the `main.rb` file in command line (providing you have ruby installed), with `.log` file paths in arguments, like so:

```
ruby lib/main.rb exampleFile1.log foo/exampleFile2.log
```

The program will convert files from file paths in arguments, and write `.gpx` file, with the same name in the specified destination. 

## Log file syntax

Files with `.log` extension this converter uses need to have a strict line format specified bellow, where each line represents one track point.

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
