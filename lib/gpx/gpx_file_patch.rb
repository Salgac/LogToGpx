#!/usr/bin/env ruby

module GPXFilePatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method :generate_xml_doc, :generate_xml_doc_new
    end
  end

  module InstanceMethods
    #generate_xml_doc from GPX::GPXFile patch
    def generate_xml_doc_new
      version_dir = version.tr(".", "/")

      gpx_header = attributes_and_nsdefs_as_gpx_attributes

      #!PATCH file version and creator
      gpx_header["version"] = @version
      gpx_header["creator"] = "LogToGpx"
      gpx_header["xsi:schemaLocation"] = "http://www.topografix.com/GPX/#{version_dir} http://www.topografix.com/GPX/#{version_dir}/gpx.xsd" unless gpx_header["xsi:schemaLocation"]
      gpx_header["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance" if !gpx_header["xsi"] && !gpx_header["xmlns:xsi"]

      # $stderr.puts gpx_header.keys.inspect

      # rubocop:disable Metrics/BlockLength
      doc = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.gpx(gpx_header) do
          #! PATCH working with version 1.0 of the schema
          xml.name @name
          xml.time @time.xmlschema
          xml.bound(
            minlat: bounds.min_lat,
            minlon: bounds.min_lon,
            maxlat: bounds.max_lat,
            maxlon: bounds.max_lon,
          )

          tracks&.each do |t|
            xml.trk do
              xml.name t.name

              t.segments.each do |seg|
                xml.trkseg do
                  seg.points.each do |p|
                    xml.trkpt(lat: p.lat, lon: p.lon) do
                      xml.time p.time.xmlschema unless p.time.nil?
                      xml.ele p.elevation unless p.elevation.nil?

                      #!PATCH main here
                      xml.speed p.speed unless p.speed.nil?
                      xml.vtram p.vtram unless p.vtram.nil?
                      xml.course p.course unless p.course.nil?
                      xml.hacc p.hacc unless p.hacc.nil?
                      #!PATCH end

                      xml << p.extensions.to_xml unless p.extensions.nil?
                    end
                  end
                end
              end
            end
            #!PATCH remove waypoints and routes
          end
        end
      end
      # rubocop:enable Metrics/BlockLength

      doc
    end
  end
end
