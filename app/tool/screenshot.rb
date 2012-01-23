# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'open-uri'
require 'gtk2/base.rb'
require 'webkit'
require 'timeout'

class Screen < Gtk::Window
  def initialize(id, url)
    super()
    @option = {
      :id   => id,
      :url  => url,
      :size => [840, 600],
      :path => File.dirname(__FILE__) + "/../tmp/#{id}.png"
    }
    self.border_width = 0
    self.resize(@option[:size][0], @option[:size][1])
  end

  def screenshot
    gdkw = self.child.parent_window
    x, y, width, height, depth = gdkw.geometry
    width -= 16
    pixbuf = Gdk::Pixbuf.from_drawable(nil, window, 0, 0, width, height)
    pixbuf = pixbuf.scale(210, 150, Gdk::Pixbuf::INTERP_HYPER)
    pixbuf.save(@option[:path], "png")
  end

  def on_net_stop
    Gtk::timeout_add(1000) do
      screenshot
      Gtk.main_quit
    end
  end
end

class ScreenShot < Screen
  def initialize(id, url)
    super
    self << Gtk::WebKit::WebView.new
    self.child.set_size_request(@option[:size][0], @option[:size][1])
    self.child.open(@option[:url])
    self.child.signal_connect("load_finished") { on_net_stop }
    self.show_all
    Gtk.init
    Gtk.main
  end
end

if ARGV[0] && ARGV[1]
  ScreenShot.new(ARGV[0], ARGV[1])
end
