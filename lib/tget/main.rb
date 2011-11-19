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
module Tget
  class Main
    include Debug
    MAX_PRIO=255
    def self.default_opts
      options={}
      options['debug']=false
      options['download_dir']=File.expand_path("~/Downloads/torrents/")
      options['config_file']=File.expand_path("~/.tget_cfg")
      options['downloaded_files']=File.expand_path("~/.downloaded_files")
      options['scraper_dir']=File.join(File.expand_path(File.dirname(__FILE__)), '/scrapers/')
      options['working_dir']=File.expand_path('.')
      options['logger']=$stdout
      options['timeout']=5
      options['min_seeds']=50
      options
    end
    def initialize options=Tget::Main.default_opts
      @options=options
      @scrapers={}
      @out= options['logger'] || nil    
      debug "Debugging output enabled"
      #config must be loaded after @out is populated to avoid NilClass errors
      @config=Tget::Config.load_config(@options)
      load_scrapers options
      @results=[]
      puts "Loaded."
    end
    attr_accessor :scrapers
    def self.max_prio
      MAX_PRIO
    end
    def load_scrapers options
      debug "Searching for scrapers in: #{options['scraper_dir']}\#{i}"
      MAX_PRIO.times {|i|
        Find.find( File.join( options['scraper_dir'], "#{i}/" )) {|s|
          next unless s[/\.rb$/]
          debug "Loading: #{s}"
          load s
          @scrapers[i]=[] unless @scrapers.has_key? i
          @scrapers[i] << File.basename(s).capitalize
        }
      }
    end
    def run
      Dir.chdir( @options['working_dir'] ) do |working_dir|
        @results=search.flatten.compact
        p_results
        download
      end
      puts "#{Time.now.to_s} -- Done."
      @results
    end
    def search
      puts "Searching for #{@config[:shows].length} shows ..."
      MAX_PRIO.times {|i|
        if @scrapers.has_key? i
          #This allows multiple scrapers within the same priority
          #but does not guarantee an order for said scrapers.
          @scrapers[i].each {|scraper|
            do_until(@options['timeout'], scraper) {
              scraper_modname=scraper.gsub(/(\.(.){2,3}){1,2}$/,'')
              debug "Working with #{scraper_modname}"

              extend Tget.const_get(scraper_modname)
              @config[:shows].each {|show|
                retries=0
                debug "Searching #{scraper_modname} for #{show}..."
                begin
                  r=search(show)
                rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, Errno::EHOSTUNREACH 
                  next if retries > MAX_RETRIES
                  debug "Connection failed, trying again... (Attempt ##{retries+1})"
                  retries+=1
                  retry
                end
                debug "Found #{r.size rescue 0} results"

                @results << r
              }
            }
          }
        end
      }
      @results
    end
    def p_results 
      debug "Results:"
      if @options['debug']
        if @results.length > 0
          @results.each {|result|
            debug result
          }
        else
          debug "No Results.\nDone."
        end
      end
    end
    def download
      puts "Downloading #{@results.length} .torrent files..."
      return 0 if @results.empty?
      if @options['download_dir'][/\/$/].nil?
        download_dir=@options['download_dir'] + '/'
      else
        download_dir=@options['download_dir']
      end
      FileUtils.mkdir_p(download_dir) unless File.exist?(download_dir)
      @results.each {|result|
        retries=0
        if File.basename(result.download).include?('.torrent')
          basename= URI.decode(File.basename(result.download))
        else
          basename= rand(999999999).to_s + ".torrent"
        end
        begin
          unless @options['dry_run']
            File.open( File.join(download_dir, basename), 'wb' ) {|file| 
              file.write open(result.download).read
              debug "Downloaded--|\n     From: #{URI.decode(result.download)}\n     To:   #{File.join(download_dir,basename)}"
            }
          end
          Tget::DList.add( result.show + DLIST_SEP + result.ep_id.to_s )
        rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, Errno::EHOSTUNREACH 
          next if retries > MAX_RETRIES
          debug "Connection failed, trying again... (Attempt ##{retries+1})"
          retries+=1
          retry
        end
      }
    end
    private
    def prep_title
      prep_title.gsub(/$/,'')
    end
    def do_until(i, prefix)
      begin
        Timeout::timeout(i) { yield() }
      rescue Timeout::Error => e
        debug prefix+": Timed Out"
      end
    end
  end
end
