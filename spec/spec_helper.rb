require File.expand_path(File.dirname(__FILE__) + "/../lib/tget")
require 'fileutils'
require 'tempfile'

module TgetSpecHelper
  def new_file(name, contents)
    File.open(name, 'w') do |f|
      f.puts contents
    end
  end
  def default_opts
    options={}
    options['debug']=false
    options['download_dir']=File.expand_path("~/Downloads/torrents/")
    options['config_file']=File.expand_path("~/.tget_cfg")
    options['downloaded_files']=File.expand_path("~/.downloaded_files")
    options['scraper_dir']=File.join(File.expand_path(File.dirname(__FILE__)), 'tget/scrapers/')
    options['working_dir']=File.expand_path('.')
    options
  end
  def fake_scraper scraper_suffix=nil
    "require 'rss'
    module Tget
      module Fakescraper#{scraper_suffix}
        def search str
          []
        end
      end
    end"
  end
end
