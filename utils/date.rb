require 'date'

# A placeholder class for holding a set number of hours.
# Used so we can know when to change the behavior
# of DateTime#-() by recognizing when hours are explicitly passed in.

class Hours
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

# Patch the #-() method to handle subtracting hours
# in addition to what it normally does

class DateTime

  alias old_subtract -

  def -(x)
    case x
    when Hours; return (Time.at(self.to_time.to_i - (x.value) * 3600).utc.to_datetime)
    when DateTime; return (self.to_time.to_i - x.to_time.to_i) / 3600
    else;       return self.old_subtract(x)
    end
  end

end

# Add an #hours attribute to Fixnum that returns an Hours object.
# This is for syntactic sugar, allowing you to write "someDate - 4.hours" for example
class Fixnum
  def hours
    Hours.new(self)
  end

  def hours_ago
     (DateTime.now - self.hours).strftime("%FT%RZ")
  end
end
