# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'sinatra'
require 'open-uri'
require File.dirname(__FILE__) + '/util/response'
require File.dirname(__FILE__) + '/util/message'
require File.dirname(__FILE__) + '/service/page'
require File.dirname(__FILE__) + '/service/screen'
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

get '/thumbnail/:id' do
  screen = ScreenService.new(params[:url])
  screen_search = screen.find(params[:id])
  if screen_search.is_success
    content_type "png"
    screen_search.data['data'].unpack('m')[0]
  else
    status 404
    "Not found"
  end
end

post '/thumbnail' do
  if params[:url].to_s.length > 0
    screen = ScreenService.new(params[:url])
    screenshot = screen.shot
    if screenshot.is_success
      response = screen.persist(screenshot.data[:id], screenshot.data[:path], params[:url])
    else
      response = Response::error({ :message => Message::Error::internal })
    end
  else
    response = Response::error({ :message => Message::Error::required_parameter("url") })
  end
  response.json
end
