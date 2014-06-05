require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    objects = []
    results.each do |hash|
      objects << self.new(hash)
    end
    objects
  end
end

class SQLObject < MassObject
  def self.columns
    columns = DBConnection.execute2("SELECT * FROM #{self.table_name}").first
    columns.map(&:to_sym).each do |column|
      self.my_attr_accessor(column)
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    result_hashes = DBConnection.execute(<<-SQL)
                      SELECT
                        *
                      FROM
                       #{@table_name}
                       SQL
    self.parse_all(result_hashes)
  end

  def self.find(id)
    result_hash = DBConnection.execute(<<-SQL, id)
                    SELECT
                      *
                    FROM
                      #{self.table_name}
                    WHERE
                      id = ?
                    SQL
    self.new(result_hash.first)
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    col_names = attributes.keys
    question_marks = ["?"] * col_names.count

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names.join(", ")})
      VALUES
        (#{question_marks.join(", ")})
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each_pair do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute #{attr_name.to_s}"
      end
      attributes[attr_name] = value
    end

    super(params)
  end

  def save
    id.nil? ? insert : update
  end

  def update
    col_names = attributes.keys
    updated_values = []
    col_names.each do |attr_name|
      updated_values << self.send(attr_name)
    end
    set_line = col_names.map{|attr_name| "#{attr_name} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *updated_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL

  end

end
