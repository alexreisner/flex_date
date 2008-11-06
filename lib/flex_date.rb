require 'date'
class FlexDate

  attr_accessor :year, :month, :day
  
  ##
  # Initialize the FlexDate with whichever are available: year, month, and day.
  #
  def initialize(year = nil, month = nil, day = nil)
    @year, @month, @day = year, month, day
  end
  
  ##
  # Does this FlexDate specify a year, month, and day?
  #
  def complete?
    not (@year and @month and @day).nil?
  end
  
  ##
  # Same as Date#strftime but gracefully removes missing parts.
  # FIXME: If any part is missing, the whole string is made empty.
  #
  def strftime(format = '%F')
    # If we have a complete date, just let Date handle it.
    return real_date.strftime(format) if complete?
    
    # If we have a partial date, define token dependencies.
    tokens = {
      :year  => %w(C c D F G g u V v w x Y y),
      :month => %w(B b c D F h m u V v w x),
      :day   => %w(A a c D d e F j u V v w x),
      :time  => %w(H I k L M N P p Q R r S s T X Z)
    }

    # Remove tokens that refer to missing parts.
    format.gsub!(/%([-_0^#]+)?(\d+)?[EO]?(:{1,3}z|.)/m) do |m|
      s, w, c = $1, $2, $3
      tokens.each do |part,token_list|
        missing = instance_variable_get("@#{part}").nil?
        return '' if (token_list.include?(c) and missing)
      end
      m
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
  # Get a phony Date object with "1" set for any unknown parts.
  #
  def phony_date
    Date.new((@year || 1), (@month || 1), (@day || 1))
  end
end
