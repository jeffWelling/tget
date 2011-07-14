# Add the directory containing this file to the start of the load path if it
# isn't there already.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'optparse'
require 'net/http'
require 'fileutils'
require 'pp'
require 'find'
require 'tget/main'
require 'tget/result'
module Tget
  autoload :VERSION, 'tget/version'

  def self.start
    options={}
    options['debug']=false
    options['download_dir']=File.expand_path("~/Downloads/torrents/")
    options['config_file']=File.expand_path("~/.tget_cfg")
    opts= OptionParser.new do |opts|
      opts.banner= "tget is a command line .torrent downloader"

      opts.on("--download-to [DIR]", "Directory to download .torrent files to") do |dir|
        options['download_dir']= dir
      end

      opts.on("--config [PATH]", "Path of config file to use instead of default") do |path|
        options['config_file']= path
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
    end
    opts.parse!
    Tget::Main.new.run( options )
  end
end
