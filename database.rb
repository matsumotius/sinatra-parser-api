# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'mysql'

class Database
  def initialize
    @mysql = { :user => @@conf['username'], :password => @@conf['password'], :database => @@conf['database'] }
    @db = Mysql.init
    @db.options(Mysql::SET_CHARSET_NAME, 'utf8')
    @db = Mysql::connect(@mysql[:localhost], @mysql[:user], @mysql[:password], @mysql[:database])
  end
end

