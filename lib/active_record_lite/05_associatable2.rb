require_relative '04_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_options.model_class.where({through_options.primary_key => self.send(through_options.foreign_key)}).first
    end
  end
end
