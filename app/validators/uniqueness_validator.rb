require 'active_model'

class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    sql = "SELECT FROM #{record.class.oclass.name}"
    sql = sql + ' WHERE ' + ConditionBuilder::OrientGraph.sql_build("#{attribute}" => value, kin_id_dne: record.committed? ? record.kin_id : '')
    puts "INSIDE VALIDATE = #{sql}"
    cmd = OrientDB::SQLSynchQuery.new(sql)
    res = Oriented.graph.command(cmd).execute
    r = res.first
    puts "R = #{r}"
    record.errors.add attribute, (options[:message] || "is not unique") unless r.nil?
  end
end