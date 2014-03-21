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
      DBConnection.execute(<<-SQL, :id => id)
      SELECT
      *
      FROM
      #{@table_name}
      WHERE
      id = :id
      SQL

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

    DBConnection.execute(<<-SQL, attribute_values)
    INSERT INTO
      #{@table_name} (#{col_names.join(", ")})
    VALUES
      (#{question_marks.join(", ")})
    SQL
    self.id = db.last_insert_row_id
  end

  def initialize(params = {})
    params.keys.each do |attr_name|
      unless self.class.columns.include?(attr_name.to_sym)
        p self.class.columns
        p attr_name
        raise "unknown attribute #{attr_name.to_s}"
      end
    end

    super(params)
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    # ...
  end
end
