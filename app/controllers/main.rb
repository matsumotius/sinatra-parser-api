# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'sinatra'
require 'open-uri'
require File.dirname(__FILE__) + '/../util/response'
require File.dirname(__FILE__) + '/../util/message'
require File.dirname(__FILE__) + '/../service/page'
require File.dirname(__FILE__) + '/../service/thumbnail'
# module
include Response
include Message::Error

before do
  unless params[:url]
    content_type "json"
    halt 400, Response::error({ :message => "Invalid Parameter Error" }).json
  end
end

get '/info' do
  page_service = PageService.new(params[:url])
  response = page_service.get_info
  response.json
end

get '/thumbnail' do
  thumbnail = ThumbnailService.new
  find_thumbnail = thumbnail.find(params[:url])
  if find_thumbnail.is_success
    content_type "png"
    find_thumbnail.data["data"].unpack('m')[0]
  else
    content_type "gif"
    open(File.dirname(__FILE__) + "/../../resource/image/404.gif").read
  end
end

post '/thumbnail' do
  content_type "json"

  if request.ip != @@conf['localhost']
    halt 403, Response::error({ :message => "Invalid Request Error" }).json
  end

  thumbnail = ThumbnailService.new
  make_thumbnail = thumbnail.make(params[:url])
  if make_thumbnail.is_success
    make_thumbnail.json
  else
    halt 500, Response::error({ :message => "Internal Error" }).json
  end
end
