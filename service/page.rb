# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require File.dirname(__FILE__) + '/../util/response'
include Response
include Message::Error

class PageService
  def initialize(url)
    @url = url
    @io = open(@url)
    @charset = @io.charset
    fix_charset if @charset == "iso-8859-1"
  end

  def fix_charset
    io_string = open(@url).read
    @charset = io_string.scan(/charset="?([^\s"]*)/i).flatten.inject(Hash.new{0}){|a, b|
      a[b]+=1
      a
    }.to_a.sort_by{|a|
      a[1]
    }.reverse.first[0]
  end

  def get_info
    begin
      @doc = Nokogiri::HTML(@io, @url, @charset)
      Response::success({ :data => { :title => get_title, :desc => get_desc } })
    rescue => e
      puts e
      Response::error({ :message => Message::Error::internal })
    end
  end

  def get_title
    title = @doc.xpath('//title').text
    title.length > 0 ? title.gsub(/\n/,"") : "no title"
  end

  def get_desc
    desc = ""
    @doc.xpath('//meta[@name="description"]').each do |meta|
      desc = meta['content']
    end
    body = @doc.xpath('//body').text.gsub(/\n/,"")
    desc.length > 0 ? desc : body[0..100]
  end
end
