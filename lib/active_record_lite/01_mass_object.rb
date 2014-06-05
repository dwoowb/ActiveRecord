require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject

  def self.attributes
    if self == MassObject
      raise "should not call #attributes on MassObject directly"
    else
      []
    end
  end

  def initialize(params = {})
    params.each_pair do |name, value|
      self.class.send(:my_attr_accessor, name.to_sym)
      self.send("#{name.to_sym}=", value)
    end
  end
end
