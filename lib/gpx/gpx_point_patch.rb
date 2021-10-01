#!/usr/bin/env ruby

module GPXPointPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method :initialize, :initialize_new
    end
  end

  module InstanceMethods
    #initialize from GPX::Point patch
    def initialize_new(opts = {})
      @lat = opts[:lat]
      @lon = opts[:lon]
      @elevation = opts[:elevation]
      @time = opts[:time]
      @speed = opts[:speed]

      #!PATCH main here
      #add new attributes
      self.class.module_eval { attr_accessor :hacc, :course }

      #set values
      @hacc = opts[:hacc]
      @course = opts[:course]
      #!PATCH end
    end
  end
end
