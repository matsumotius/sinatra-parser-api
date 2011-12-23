# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'open-uri'
require 'digest/md5'
require File.dirname(__FILE__) + '/../util/response'
require File.dirname(__FILE__) + '/../util/message'
require File.dirname(__FILE__) + '/../dao/thumbnail'
include Response
include Message::Error

class ThumbnailService
  def initialize(url)
    @url = url
    @option = { :url => @url, :id => Digest::MD5.hexdigest(Time.now.to_i.to_s) }
    @thumbnail = Thumbnail.new
  end

  def get
    begin
      command = "web-snapshooter -u #{@option[:url]} --output-file tmp/#{@option[:id]}.png --browser-size 800x800 --output-size 160x160"
      `#{command}`
      Response::success({ :data => { :id => "#{@option[:id]}", :path => "tmp/#{@option[:id]}.png" } })
    rescue => e
      puts e
      Response::error({ :message => Message::Error::internal })
    end
  end

  def persist(id, path, url)
    begin
      data = [open(path).read].pack("m")
      @thumbnail.save(id, data, url)
      Response::success({ :data => { :id => id } })
    rescue => e
      puts e
      Response::error({ :message => Message::Error::internal })
    end
  end

  def find(url)
    begin
      result = @thumbnail.find_by_url(url)
      if result
        Response::success({ :data => result })
      else
        Response::error({ :message => Message::Error::internal })
      end
    rescue => e
      puts e
      Response::error({ :message => Message::Error::internal })
    end
  end
end
