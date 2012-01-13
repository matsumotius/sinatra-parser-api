# -*- encoding: UTF-8 -*-
class QueryBuilder
  def initialize
    @query = ''
    @operation = ''
    @attribute = { 'column' => '', 'table' => '', 'set' => [], 'where' => '', 'and' => [], 'or' => [], 'limit' => '', 'order' => '' }
  end

  def attribute(key)
    @attribute[key]
  end

  def select(column)
    raise Exception, 'empty params' if column.to_s == ''
    @operation = 'SELECT'
    @attribute['column'] = column
    return self
  end

  def update(table)
    @operation = 'UPDATE'
    @attribute['table'] = table
    return self
  end

  def delete(table)
    @operation = 'DELETE'
    @attribute['table'] = table
    return self
  end

  def insert(table)
    @operation = 'INSERT'
    @attribure['table'] = table
    return self
  end

  def from(table)
    raise Exception, 'empty params' if table.to_s == ''
    raise Exception, 'wrong operation' unless @operation == 'SELECT'
    @attribute['table'] = table.to_s
    return self
  end

  def limit(a, b = '')
    raise Exception, 'empty params' if a.to_s == ''
    limit = "LIMIT #{a}"
    limit += ", #{b}" unless b.to_s == ''
    @attribute['limit'] = limit
    return self
  end

  def order(sort, by = 'ASC')
    raise Exception, 'empty params' if sort.to_s == ''
    order = "ORDER BY #{sort}"
    order += " #{by}"
    @attribute['order'] = order
    return self
  end

  def convert_string(value)
    value.class.to_s == 'String' ? '"'+value+'"' : value.to_s
  end

  def set(key, value)
    raise Exception, 'empty params' if key.to_s == ''
    @attribute['set'].push({ 'key' => key, 'value' => convert_string(value) })
    return self
  end

  def where(key, relation, value)
    raise Exception, 'empty params' if key.to_s == '' or relation.to_s == ''
    @attribute['where'] = { 'key' => key, 'relation' => relation, 'value' => convert_string(value) }
    return self
  end

  def and(key, relation, value)
    raise Exception, 'empty params' if key.to_s == '' or relation.to_s == ''
    @attribute['and'].push({ 'key' => key, 'relation' => relation, 'value' => convert_string(value) })
    return self
  end

  def or(key, relation, value)
    raise Exception, 'empty params' if key.to_s == '' or relation.to_s == ''
    @attribute['or'].push({ 'key' => key, 'relation' => relation, 'value' => convert_string(value) })
    return self
  end

  def build
    builder = Builder.new(@attribute)
    if @operation == 'SELECT'
      return builder.build_select
    elsif @operation == 'UPDATE'
      return builder.build_update
    elsif @operation == 'DELETE'
      return builder.build_delete
    end
  end

  class Builder
    def initialize(attribute)
      @query = ''
      @attribute = attribute
    end

    def build_where
      return '' if @attribute['where'].nil?
      str = "WHERE #{@attribute['where']['key']} #{@attribute['where']['relation']} #{@attribute['where']['value']} "
      @attribute['and'].each do |obj| str += "AND #{obj['key']} #{obj['relation']} #{obj['value']} " end
      @attribute['or'].each do |obj| str += "OR #{obj['key']} #{obj['relation']} #{obj['value']} " end
      str
    end

    def build_set
      return '' if @attribute['set'].nil?
      str = 'SET '
      @attribute['set'].each_with_index do |obj, index|
        str += ', 'if index > 0
        str += "#{obj['key']} = #{obj['value']}"
      end
      str + ' '
    end

    def build_order
      "#{@attribute['order']} "
    end

    def build_limit
      "#{@attribute['limit']} "
    end

    def build_select
      @query += "SELECT #{@attribute['column']} FROM #{@attribute['table']} "
      @query += build_where
      @query += build_order
      @query += build_limit
      return @query.strip
    end

    def build_update
      @query += "UPDATE #{@attribute['table']} "
      @query += build_set
      @query += build_where
      @query += build_order
      @query += build_limit
      return @query.strip
    end

    def build_delete
      @query += "DELETE FROM #{@attribute['table']} "
      @query += build_where
      @query += build_order
      @query += build_limit
      return @query.strip
    end
  end 
end

