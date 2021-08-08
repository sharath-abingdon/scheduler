#
# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2021 John Winters
# See COPYING and LICENCE in the root directory of the application
# for more information.
#

#
#  And object which can work out possible clashes for an EventCollection
#  and the resources controlled by a user.
#

class ClashDetector

  #
  #  An individual clash message.
  #

  class ClashMessage
    def initialize(commitment)
      @commitment = commitment
    end

    def to_s
      event = @commitment.event
      "#{event.starts_at.to_s(:dmy)} - #{event.duration_or_all_day_string} - #{event.body}"
    end

    def to_partial_path
      'clash_message'
    end
  end

  #
  #  Holds all the clashes for one particular resource.
  #
  #  This was originally implemented as a sub-class of Array which is
  #  cleaner, but then leads to problems with Rails's render function.
  #  There doesn't seem to be a clean way to tell it to render the
  #  object as an array.
  #
  class ClashSet

    attr_reader :messages

    def initialize(element)
      @element = element
      @messages = Array.new
    end

    def resource_name
      @element.name
    end

    def to_partial_path
      'clash_set'
    end

    def <<(item)
      @messages << item
    end

    def empty?
      @messages.empty?
    end

  end

  def initialize(event_collection, event, user)
    @event_collection = event_collection
    @event = event
    @user = user
  end

  #
  #  Check for clashes for resources owned by the indicated user with
  #  events which would be generated by this event_collection.
  #
  #  Returns an array - possibly empty - of ClashSets.  One ClashSet
  #  per resource which the user owns, and which has clashes.
  #
  def detect_clashes
    result = []
    @user.owned_elements.each do |element|
      clash_set = ClashSet.new(element)
      EventRepeater.test_for_clashes(@event_collection,
                                     @event,
                                     element) do |commitment|
        #
        #  We have an apparent clash.
        #
        Rails.logger.debug("An apparent clash")
        clash_set << ClashMessage.new(commitment)
      end
      unless clash_set.empty?
        result << clash_set
      end
    end
    return result
  end

end

