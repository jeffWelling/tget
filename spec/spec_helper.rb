require File.expand_path(File.dirname(__FILE__) + "/../lib/tget")
require 'fileutils'
require 'tempfile'

TGET_HISTORY= StringIO.new

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
  def fake_scraper scraper_suffix=nil, search_str=nil
    "require 'rss'
    module Tget
      module Fakescraper#{scraper_suffix}
        #{if search_str.nil? 
        "def search str
          []
        end"
          else
        search_str
        end}
      end
    end"
  end
  #This is used by the spec that checks that the search method of a scrapre actually gets passed
  # a value from the config file. 
  # Very Ugly Hack -- FIXME
  class DStore
    @@value=[]
    def self.store value
      @@value << value
    end
    def self.get
      @@value
    end
  end
end
