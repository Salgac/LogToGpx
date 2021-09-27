#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require(:default)

ARGV.each do |file|
  file_name, extension = file.split(".")
  puts "Parsing file \"#{file}\"…"

  gpx_points = []

  File.open(file, "r") do |f|
    f.each_line do |line|
      time, _, lat, _, lon, _, hmsl, _, gspeed, _, crs, _, hacc = line.split(";")

      #convert data
      time_stamp = Time.parse(time[0..22].sub(" ", "T") + "Z")
      lat = lat.to_f / 10000000
      lon = lon.to_f / 10000000
      hmsl = hmsl.to_f / 1000
      gspeed = gspeed.to_f / 27.778
      crs = crs #?
      hacc = hacc.to_f / 1000000

      #print into gpx point structure
      gpx_points << GPX::Point.new({
        time: time_stamp,
        lat: lat,
        lon: lon,
        elevation: hmsl,
        speed: gspeed,
      })
    end
  end

  #generate GPX structure
  gpx_file = GPX::GPXFile.new({ version: "1.0" })
  gpx_segment = GPX::Segment.new
  gpx_track = GPX::Track.new

  gpx_segment.points = gpx_points
  gpx_track.segments = [gpx_segment]
  gpx_track.name = file_name
  gpx_file.tracks = [gpx_track]

  gpx_file.write(file_name + ".gpx")
end
