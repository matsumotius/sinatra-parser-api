# -*- encoding: UTF-8 -*-
require File.dirname(__FILE__) + '/../database'
require File.dirname(__FILE__) + '/../util/message'
require File.dirname(__FILE__) + '/../util/querybuilder'

class Thumbnail < Database
  def find_by_id(id)
    query = QueryBuilder.new
    query = query.select('*').from('thumbnail').where('id', '=', id)
    rows = @db.query(query.build)
    rows.fetch_hash
  end

  def find_by_url(url)
    query = QueryBuilder.new
    query = query.select('*').from('thumbnail').where('url', '=', url)
    rows = @db.query(query.build)
    rows.fetch_hash
  end

  def save(id, data, url)
    query = 'INSERT INTO thumbnail(id, data, url) VALUES (?, ?, ?)'
    statement = @db.prepare(query)
    result = statement.execute(id, data, url).insert_id
    statement.close
    result
  end
end
