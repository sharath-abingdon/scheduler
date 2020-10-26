#
# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2020 John Winters
# See COPYING and LICENCE in the root directory of the application
# for more information.
#

require 'tod'

class FreeSlotFinder

  def initialize(elements, mins_required, start_time, end_time)
    elements.each do |e|
      unless e.instance_of?(Element)
        raise ArgumentError.new("Not an element - #{e.class}")
      end
    end
    @elements = elements
    if mins_required.kind_of?(Integer) && mins_required > 0
      @mins_required = mins_required
    else
      raise ArgumentError.new("mins_required must be a positive integer")
    end
    case start_time
    when String
      @start_time = Tod::TimeOfDay.parse(start_time)
    when Tod::TimeOfDay
      @start_time = start_time
    else
      raise ArgumentError.new("Invalid start time")
    end
    case end_time
    when String
      @end_time = Tod::TimeOfDay.parse(end_time)
    when Tod::TimeOfDay
      @end_time = end_time
    else
      raise ArgumentError.new("Invalid end time")
    end
    if @end_time < @start_time
      raise ArgumentError.new("Backwards time slot")
    end
  end

  def slots_on(date)
    free_times = TimeSlotSet.new([@start_time, @end_time])
    @elements.each do |element|
      commitments =
        element.commitments_on(startdate: date).preload(event: :eventcategory)
      commitments.each do |commitment|
        event = commitment.event
        unless Eventcategory.non_busy_categories.include?(event.eventcategory)
          free_times -= event.time_slot_on(date)
        end
      end
    end
    free_times
  end
end
