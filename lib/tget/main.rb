module Tget
  class Main
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
      options
    end
    def initialize options=Tget::Main.default_opts
      @options=options
      @scrapers={}
      @out= options['logger'] || nil    
      debug "Debugging output enabled"
      #config must be loaded after @out is populated to avoid NilClass errors
      @config=load_config
      load_scrapers options
      @results=[]
    end
    attr_accessor :scrapers
    def self.max_prio
      MAX_PRIO
    end
    def load_scrapers options
      puts "Searching for scrapers in: #{options['scraper_dir']}\#{i}" if options['debug']
      MAX_PRIO.times {|i|
        Find.find( File.join( options['scraper_dir'], "#{i}/" )) {|s|
          next unless s[/\.rb$/]
          puts "Loading: #{s}" if options['debug']
          load s
          @scrapers[i]=[] unless @scrapers.has_key? i
          @scrapers[i] << File.basename(s).capitalize
        }
      }
    end
    def run
      Dir.chdir( @options['working_dir'] ) do |working_dir|
        #load config

        @results=search.flatten.compact
        p_results

        #download file
        download
      end
      @results
    end
    def search
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
        @results.each {|result|
          puts result
        }
      end
    end
    def download
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
          basename= File.basename(result.download)
        else
          basename= rand(999999999).to_s + ".torrent"
        end
        begin
          File.open( File.join(download_dir, basename), 'wb' ) {|file| 
            file.write open(result.download).read 
          } and Tget::DList.add( result.show + DLIST_SEP + result.ep_id.to_s )
        rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, Errno::EHOSTUNREACH 
          next if retries > MAX_RETRIES
          debug "Connection failed, trying again... (Attempt ##{retries+1})"
          retries+=1
          retry
        end
      }
    end
    def debug str
      puts str if @options['debug']
    end
    def load_config
      config={}
      listing_shows=true
      config[:shows]=[]
      unless (file= (File.open(@options['config_file'], 'r') rescue nil))
        unless @options['silent_mode']
          puts "Could not open config file: \n#{@options['config_file']}\nCheck permissions?\n\nWithout a config file, we have no shows to search for. Exiting..."
        end
        raise "Config file not found"
      end
      while( line=file.gets )
        if listing_shows==true
          if line[Regexp.new(CONFIG_DELIM)]
            listing_shows=false
            next
            debug "Entering config options section"
          end
          config[:shows] << line.strip
          debug "Adding show '#{line.strip}'"
        else
          config[line[/^[^=]*/]]=line.gsub(/^[^=]*=/,'').strip
        end
      end
      file.close
      if @options['debug']
        puts"Config:  \n"
        config.sort {|x,y| x[0].to_s <=> y[0].to_s}.each {|key,value|
          if key==:shows
            puts "   Shows: --|"
            value.each {|show|
              puts "            #{show}"
            }
          else
            puts "   "+key
            puts "       "+value
          end
        }
      end
      config
    end
    def puts(*strings)
      @out.puts(*strings) 
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
