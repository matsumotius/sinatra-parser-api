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
  def initialize
    @option = { :id => Digest::MD5.hexdigest(Time.now.to_i.to_s) }
    @thumbnail = Thumbnail.new
  end

  def response_without_image(data)
    Response::success({ :data => { "id" => data["id"], "url" => data["url"] } })
  end

  def make(url)
    begin
      find_thumbnail = self.find(url)
      if find_thumbnail.is_success
        return response_without_image(find_thumbnail.data)
      end

      xvfb_command = "xvfb-run -a --server-args=\"-screen 0 700x500x24\""
      ruby_command = "ruby #{File.dirname(__FILE__)}/../tool/screenshot.rb #{@option[:id]} #{url}"
      `#{xvfb_command} #{ruby_command}`

      save_thumbnail = self.persist(@option[:id], "#{File.dirname(__FILE__)}/../tmp/#{@option[:id]}.png", url)
      if save_thumbnail.is_success
        return response_without_image(save_thumbnail.data)
      end
    rescue => e
      puts e
      Response::error({ :message => Message::Error::internal })
    end
  end

  def persist(id, path, url)
    begin
      data = [open(path).read].pack("m")
      @thumbnail.save(id, data, url)
      Response::success({ :data => { "id" => id, "url" => url, "data" => data } })
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
