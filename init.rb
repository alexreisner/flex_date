##
# Integration of FlexDate with ActiveRecord.
#
module MultipartDate
  def multipart_date(*attrs)
    attrs.map{ |a| a.to_s }.each do |attr|
      define_method attr do
        y, m, d = %w(y m d).map{ |i| read_attribute(attr + "_" + i) }
        FlexDate.new(y, m, d)
      end
      define_method(attr + '?') do
        %w(y m d).map{ |i| read_attribute(attr + "_" + i) }.compact.size > 0
      end
      # TODO: define setter (takes date string?)?
    end
  end
end

ActiveRecord::Base.send(:extend, MultipartDate)
