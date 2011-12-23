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

get '/info' do
  if params[:url].to_s.length > 0
    page_service = PageService.new(params[:url])
    response = page_service.get_info
  else
    response = Response::error({ :message => Message::Error::required_parameter("url") })
  end
  response.json
end

get '/thumbnail' do
  if params[:url].to_s.length > 0
    thumbnail = ThumbnailService.new(params[:url])
    get_thumbnail = thumbnail.get
    if get_thumbnail.is_success
      content_type "png"
      get_thumbnail.data['data'].unpack('m')[0]
    else
      status 404
    end
  else
    status 400
  end
end
