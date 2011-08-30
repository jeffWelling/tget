# Add the directory containing this file to the start of the load path if it
# isn't there already.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'optparse'
require 'net/http'
require 'fileutils'
require 'pp'
require 'find'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'timeout'
require 'tget/debug'
require 'tget/main'
require 'tget/result'
require 'tget/dlist'
require 'tget/episodeid.rb'
DLIST_SEP="#GNU_FTW#"
MAX_RETRIES=0
CONFIG_DELIM="### Options ###"
module Tget
  autoload :VERSION, 'tget/version'
  def self.start
    options=parse_opts
    begin
      #@@options=options
      extend Debug
      these_be_options options
      Tget::DList.load options['downloaded_files']
      single_instance { Tget::Main.new( options ).run }
    ensure
      Tget::DList.save options['downloaded_files']
    end
  end
  def self.parse_opts
    options=Tget::Main.default_opts
    opts= OptionParser.new do |opts|
      opts.banner= "tget is a command line .torrent downloader"

      opts.on("--download-to [DIR]", "Directory to download .torrent files to") do |dir|
        options['download_dir']= dir
      end

      opts.on("--downloaded_files [PATH]", "Path to substitude downloaded_files list instead of ~/.downloaded_files") do |path|
        options['downloaded_files']= path
      end

      opts.on("--config [PATH]", "Path of config file to use instead of default") do |path|
        options['config_file']= path
      end

      opts.on("--scrapers [PATH]", "Path to the scrapers") do |path|
        options['scraper_dir']= path
      end

      opts.on("--working-dir [PATH]", "Alternate working directory") do |path|
        options['working_dir']= path
      end

      opts.on("--debug", "Activate debug logging") do |v|
        if options['silent']==true
          puts "--silent and --debug are mutually exclusive, cannot use both"
          raise ArgumentError
        end
        options['debug']=true
      end

      opts.on("--silent", "Silence all output") do |v|
        options['silent_mode']=true
      end

      opts.on("--timeout SECONDS", "Number of seconds to wait for execution of a scraper to complete") do |v|
        options['timeout']=v.to_i
      end
    end
    opts.parse!
    options
  end
  def self.single_instance(&block)
    if File.open($0).flock(File::LOCK_EX|File::LOCK_NB)
      block.call
    else
      warn "Tget is already running"
    end
  end
end
