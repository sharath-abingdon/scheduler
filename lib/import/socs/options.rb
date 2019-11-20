#
# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2019 John Winters
# See COPYING and LICENCE in the root directory of the application
# for more information.
#

require 'optparse'
require 'optparse/date'

class Options

  attr_reader :verbose,
              :start_date,
              :end_date,
              :attached_elements,
              :event_category_name,
              :merge_type,
              :allow_timeless,
              :default_duration


  def initialize(element_engine)
    @verbose             = false
    @start_date          = Date.today
    @end_date            = nil
    @event_category_name = "Sport"
    @merge_type          = nil
    @default_duration    = 0
    @allow_timeless      = false
    @attached_elements   = Array.new
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: socsimport.rb [options]"

      opts.on("-v", "--verbose", "Run verbosely") do |v|
        @verbose = v
      end

      opts.on("-s", "--start-date [DATE]", Date,
              "Specify an over-riding start date",
              "for loading events.  Defaults to today.") do |date|
        @start_date = date
      end

      opts.on("-e", "--end-date [DATE]", Date,
              "Specify an over-riding end date",
              "for loading events.  Defaults to none.") do |date|
        @end_date = date
      end

      opts.on("-a", "--attach [ELEMENT]", 
              "Specify an element to be attached to",
              "all fixtures.  Can be either a name",
              "or an element id.  Can be specified",
              "multiple times.") do |element_name|
        element = element_engine.find(element_name)
        if element
          @attached_elements << element
        else
          raise "Element \"#{element_name}\" not found."
        end
      end

      opts.on("-c", "--category [EVENTCATEGORY]",
              "Specify the name of the event category",
              "to be used for all the fixtures.",
              "Defaults to \"Sport\".") do |name|
        
        @event_category_name = name
      end

      opts.on("-m", "--merge <home/away/both>",
              "Specify which types of fixtures should",
              "be merged - home fixtures, away fixtures",
              "or both.") do |type|
        lower_type = type.downcase
        if ['home', 'away', 'both'].include?(lower_type)
          @merge_type = lower_type.to_sym
        else
          raise "Merge type should be \"home\", \"away\" or \"both\", not \"#{type}\"."
        end
      end

      opts.on("-d", "--duration [MINS]", Integer,
              "Give a default duration for fixtures with",
              "no explicit end time.  Defaults to 0") do |duration|

        @default_duration = duration
      end

      opts.on("-n", "--notime",
              "Allow fixtures to be loaded even if they",
              "have merely a date and no time specified.",
              "They will be loaded as all-day events.") do
        @allow_timeless = true
      end

      opts.on("-h", "--help",
              "Show this message") do
        puts opts
        exit
      end

    end
    begin
      parser.parse!
    rescue Exception => e
      #
      #  Interestingly, "exit" itself is an exception which can be
      #  caught, but we don't want to.
      unless e.class == SystemExit
        puts
        puts e
        puts
        puts parser
      end
      exit
    end
    parser
  end

end
