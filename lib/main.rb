#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require(:default)

#include a patch for GPX::Point
require_relative "gpx/gpx_point_patch"
unless GPX::Point.included_modules.include? GPXPointPatch
  GPX::Point.send(:include, GPXPointPatch)
end

#include a patch for xml printing method
require_relative "gpx/gpx_file_patch"
unless GPX::GPXFile.included_modules.include? GPXFilePatch
  GPX::GPXFile.send(:include, GPXFilePatch)
end

#no selected file edgecase
if ARGV.length == 0
  puts "No file in ARGV. Please specify a file path."
  return
end

#load files and export data
ARGV.each do |file|
  #check extension
  if File.extname(file) != ".log"
    puts "#{File.basename(file)} must be a \".log\" file."
    next
  end

  #prepare file
  file_name = file.delete_suffix(".log")
  print "Parsing file \"#{File.basename(file)}\"…"

  gpx_points = []

  File.open(file, "r") do |f|

    #open tram file and create a hash with time key and speed value
    time = f.readline.split(";")
    day = Time.parse(time[0]).day
    tram_file = day == 17 ? "./data/tram17.txt" : day == 18 ? "./data/tram18.txt" : nil

    if tram_file != nil
      tram_file_hash = Hash.new
      tram_lines = File.readlines(tram_file)
      tram_lines.each_with_index do |line, index|
        next if index == 0 || index == 1

        _, _, _, fileTime, _, speed, _ = line.encode("UTF-8", :invalid => :replace).split("\t")

        if speed != ""
          # 2 second offset for tram speed time difference
          stamp = (Time.parse(fileTime) - 2).strftime("%H:%M:%S")
          tram_file_hash[stamp] = speed
        end
      end
    end

    #extract point info from file
    f.rewind
    f.each_line do |line|
      time, _, lat, _, lon, _, hmsl, _, gspeed, _, crs, _, hacc = line.split(";")

      #convert data
      time_stamp = Time.parse(time[0..22].sub(" ", "T") + "Z")
      lat = lat.to_f / 10000000
      lon = lon.to_f / 10000000
      hmsl = hmsl.to_f / 1000
      gspeed = gspeed.to_f / 100
      vtram = tram_file != nil ? tram_file_hash[time_stamp.to_s[11..18]].to_f / 3.6 : nil
      crs = crs
      hacc = hacc.to_f / 1000000

      #print into gpx point structure
      gpx_points << GPX::Point.new({
        time: time_stamp,
        lat: lat,
        lon: lon,
        elevation: hmsl,
        speed: gspeed,
        vtram: vtram.nil? ? "" : vtram.round(2),
        course: crs,
        hacc: hacc,
      })
    end
  end

  #generate GPX structure
  gpx_file = GPX::GPXFile.new({ version: "1.0" })
  gpx_segment = GPX::Segment.new
  gpx_track = GPX::Track.new

  gpx_segment.points = gpx_points
  gpx_track.segments = [gpx_segment]
  gpx_track.name = File.basename(file).delete_suffix(".log")
  gpx_file.tracks = [gpx_track]

  gpx_file.write(file_name + ".gpx")
  puts "\r\"#{file_name}.gpx\" saved successfully."
end

puts "Finished"
