require 'date'
class FlexDate
  include Comparable
  
  def <=>(other)
    spaceship = 0 # start assuming equal
    %w(year month day).each do |p|
      a = eval("self.#{p}") || 0
      b = eval("other.#{p}") || 0
      break if (spaceship = a <=> b) != 0
    end
    spaceship
  end
  
  def ==(other)
    [year,month,day] == [other.year, other.month, other.day]
  end
  
  attr_accessor :year, :month, :day
  
  ##
  # Initialize the FlexDate with whichever are available: year, month, and day.
  #
  def initialize(year = nil, month = nil, day = nil)
    @year, @month, @day = year, month, day
  end
  
  ##
  # Define some preset date formats.
  #
  DATE_FORMATS = {
    :short      => "%b %e",
    :medium     => "%e %b %Y",
    :long       => "%B %e, %Y",
    :db         => "%Y-%m-%d",
    :number     => "%Y%m%d",
    :rfc822     => "%e %b %Y"
  }

  ##
  # String representation of a date. Pass a <tt>strftime</tt>-format string
  # or a symbol which is a key in the DATE_FORMATS hash.
  #
  def to_s(format = :medium)
    format = DATE_FORMATS[format] if format.is_a?(Symbol)
    s = strftime(format)
    
    # Do some rough cleanup (this isn't very "programmatic").
    replacements = [
      [/^[ ,]+/, ''], # leading whitespace and commas
      [/[ ,]+$/, ''], # trailing whitespace and commas
      [/ +, +/, ' '], # commas and whitespace in middle
    ]
    s.strip!
    replacements.each do |r|
      s.gsub!(r[0], r[1])
    end
    s
  end
  
  ##
  # Does this FlexDate specify a year, month, and day?
  #
  def complete?
    not (@year and @month and @day).nil?
  end
  
  ##
  # Same as Date#strftime but gracefully removes missing parts.
  #
  def strftime(format = '%F')
    # If we have a complete date, just let Date handle it.
    return real_date.strftime(format) if complete?
    
    # If we have a partial date, define token dependencies.
    dependencies = {
      :year  => %w(C c D F G g u V v w x Y y),
      :month => %w(B b c D F h m u V v w x),
      :day   => %w(A a c D d e F j u V v w x),
      :time  => %w(H I k L M N P p Q R r S s T X Z)
    }

    # Remove tokens that refer to missing parts.
    format = format.gsub(/%([-_0^#]+)?(\d+)?[EO]?(:{1,3}z|.)/m) do |m|
      s, w, c = $1, $2, $3
      ok = true
      dependencies.each do |attr,tokens|
        missing = instance_variable_get("@#{attr}").nil?
        ok = false if (tokens.include?(c) and missing)
      end
      ok ? m : ''
    end
    phony_date.strftime(format)
  end
  
  ##
  # Pass unimplemented methods along to a regular Date object if possible.
  #
  def method_missing(name, *args)
    real_date.send(name, *args) if complete?
  end
  
  
  private # -------------------------------------------------------------------
  
  ##
  # Get a Date object based on the current values of @year, @month, and @day.
  # Returns nil unless all three are known.
  #
  def real_date
    Date.new(@year, @month, @day) if complete?
  end
  
  ##
  # Get a Date object with "1" set for any unknown parts.
  #
  def phony_date
    Date.new((@year || 1), (@month || 1), (@day || 1))
  end
end
