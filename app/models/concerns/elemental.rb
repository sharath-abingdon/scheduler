# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2014 John Winters
# Portions Copyright (C) 2014 Abindon School
# See COPYING and LICENCE in the root directory of the application
# for more information.

module Elemental
  extend ActiveSupport::Concern

  included do
    has_one :element, :as => :entity, :dependent => :destroy

    after_save :update_element

  end

  module ClassMethods
  end

  #
  #  This method makes sure we keep our element record.
  #
  def update_element
    if self.element
      if self.active
        if self.element.name != self.element_name ||
           self.element.current != self.current
          self.element.name    = self.element_name
          self.element.current = self.current
          self.element.save!
        end
      else
        #
        #  An inactive entity shouldn't have an element.
        #
        self.element.destroy
      end
    else
      if self.active
        Element.create!(:name => self.element_name,
                        :current => self.current,
                        :entity => self)
      end
    end
  end

  #
  #  An entity may well want to override this.
  #
  def display_name
    self.name
  end

  #
  #  And shims to provide access to the instance methods in Element
  #
  def groups(given_date = nil, recurse = true)
    self.element.groups(given_date, recurse)
  end

end
