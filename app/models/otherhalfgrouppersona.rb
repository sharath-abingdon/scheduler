# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2014 John Winters
# See COPYING and LICENCE in the root directory of the application
# for more information.

class Otherhalfgrouppersona < ApplicationRecord

  include Persona

  self.per_page = 15

  def active
    true
  end

  def user_editable?
    false
  end
end
