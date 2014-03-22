require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = []
    values = params.values
    params.keys.each do |attr_name|
      where_line << "#{attr_name} = ?"
    end
    DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{@table_name}
      WHERE
        #{where_line.join(", ")}
      SQL

  end
end

class SQLObject
  include Searchable

  def self.where(params)

  end

end
