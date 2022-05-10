#!/usr/bin/env ruby

#TODO update README.md to cover this script

require "nokogiri"

SPEED_OFFSET_LIMIT = 4
entries = Array.new

# no selected file edgecase
if ARGV.length == 0
  puts "No file in ARGV. Please specify a file path."
  return
end

##############
# LOAD FILES #
##############

ARGV.each do |file|
  # check extension
  if File.extname(file) != ".gpx"
    puts "#{File.basename(file)} must be a \".gpx\" file. Skipping..."
    next
  end

  # parse file
  doc = Nokogiri::XML(open(file))
  trackpoints = doc.xpath("//trkpt")

  trackpoints.each do |trkpt|
    lat = trkpt.xpath("@lat").to_s
    lon = trkpt.xpath("@lon").to_s
    vtram = trkpt.search("vtram").text
    vgps = trkpt.search("speed").text
    hacc = trkpt.search("hacc").text

    # skip if either value not present
    if vtram == "" || vgps == "" || hacc == ""
      next
    end

    # push into common Array
    entries << { lat: lat, lon: lon, vtram: vtram, vgps: vgps, hacc: hacc }
  end
end

if entries.length == 0
  puts "No valid entries"
  return
end

###############
# CALCULATION #
###############
offset_count = 0
hacc_max = 0
hacc_min = 10000
hacc_place = ""
offset = 0

entries.each do |entry|
  diff = entry[:vgps].to_f - entry[:vtram].to_f
  hacc = entry[:hacc].to_f

  # only count offset if in limit bounds
  if diff.abs < SPEED_OFFSET_LIMIT
    offset += diff.abs
    offset_count += 1
  end

  # hacc max and min
  if hacc_max < hacc
    hacc_max = hacc
    hacc_place = entry[:lat] + ", " + entry[:lon]
  end

  if hacc_min > hacc
    hacc_min = hacc
  end
end

##########
# OUTPUT #
##########

puts "Claculation on #{ARGV.length} files."
puts "Total entries: " + offset_count.to_s
puts "----"
puts "Average speed offset (m/s): " + (offset / offset_count).to_s
puts "Average speed offset (km/h): " + (offset / offset_count * 3.6).to_s
puts "----"
puts "Hacc max (cm): " + (hacc_max * 100).to_s
puts "Hacc min (cm): " + (hacc_min * 100).to_s
puts "Place of hacc max (lat, lon):\n\t" + hacc_place
puts "----"
puts "Finished"
