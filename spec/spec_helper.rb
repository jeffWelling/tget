#    This file is part of tget.
#    Copyright 2011 Jeff Welling
#
#    tget is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    tget is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with tget.  If not, see <http://www.gnu.org/licenses/>.
#
require File.expand_path(File.dirname(__FILE__) + "/../lib/tget")
require 'fileutils'
require 'tempfile'
TGET_HISTORY = StringIO.new
module TgetSpecHelper
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
    def self.clear
      @@value=[]
    end
  end
  def new_file(name, contents)
    File.open(name, 'w') do |f|
      f.puts contents
    end
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
  def cli(opts, &block)
    TGET_HISTORY.truncate 0
    TGET_HISTORY.rewind
    options= (opts || default_opts)
    options['logger']=TGET_HISTORY
    tget=Tget::Main.new(options)
    tget.run
    rescue SystemExit => error
    if block_given?
      replay_history(&block)
    else
      TGET_HISTORY
    end
  end
  def replay_history
    TGET_HISTORY.rewind
    return unless block_given?

    while line=TGET_HISTORY.gets
      yield(line.strip)
    end
  end
end
