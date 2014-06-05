require_relative 'db_connection'
require_relative '02_sql_object'
require 'debugger'

module Searchable
  def where(params)
    where_line = []
    values = params.values# .map{|value| value.to_s}
    params.keys.each do |attr_name|
      where_line << "#{attr_name} = ?"
    end
    hash_results = DBConnection.execute(<<-SQL, *values)
                    SELECT
                      *
                    FROM
                      #{self.table_name}
                    WHERE
                      #{where_line.join(" AND ")}
                    SQL
    self.parse_all(hash_results)
  end
end

class SQLObject
  extend Searchable
end
