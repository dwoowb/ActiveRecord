require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  attr_reader :table_name

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.class_name.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase
    @foreign_key = options[:foreign_key] ? options[:foreign_key] : (name.to_s + "_id").to_sym
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] ? options[:foreign_key] : (self_class_name.downcase.to_s + "_id").to_sym
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      options.model_class.where({options.primary_key => self.send(options.foreign_key)}).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      options.model_class.where({options.foreign_key => self.send(options.primary_key)})
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
