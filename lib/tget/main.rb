module Tget
  class Main
    SCRAPERS={}
    MAX_PRIO=255
    #For debugging
    def self.SCRAPERS
      SCRAPERS
    end
    def self.MAX_PRIO
      MAX_PRIO
    end

    def initialize options={}
      @@options=options
      
      Tget::Main.load_scrapers options
    end
    def self.load_scrapers options
      puts "Searching for scrapers in: #{options['scraper_dir']}\#{i}" if options['debug']
      MAX_PRIO.times {|i|
        Find.find( File.join( options['scraper_dir'], "#{i}/" )) {|s|
          next unless s[/\.rb$/]
          puts "Loading: #{s}" if options['debug']
          load s
          SCRAPERS[i]=[] unless SCRAPERS.has_key? i
          SCRAPERS[i] << File.basename(s).capitalize
        }
      }
    end
    def run(options)
      Dir.chdir( options['working_dir'] ) do |working_dir|
        @@options=options
        debug "Debugging output enabled"
        #load config
        results=[]
        config=load_config

        #call SCRAPERS
        MAX_PRIO.times {|i|
          if SCRAPERS.has_key? i
            #This allows multiple scrapers within the same priority
            #but does not guarantee an order for said scrapers.
            SCRAPERS[i].each {|scraper|
              debug "Working with #{scraper.gsub(/(\.(.){2,3}){1,2}$/,'')}"

              extend Tget.const_get(scraper.gsub(/(\.(.){2,3}){1,2}$/,''))
              config[:shows].each {|show|
                retries=0
                debug "Searching #{scraper.gsub(/(\.(.){2,3}){1,2}$/,'')} for #{show}..."
                begin
                  r=search(show)
                rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError 
                  next if retries > MAX_RETRIES
                  debug "Connection failed, trying again... (Attempt ##{retries+1})"
                  retries+=1
                  retry
                end
                debug "Found #{r.size rescue 0} results"

                results << r
              }
            }
          end
        }
        results=results.flatten.compact

        debug "Results:"
        if options['debug']
          pp results
        end

        #download file
        if options['download_dir'][/\/$/].nil?
          download_dir=options['download_dir'] + '/'
        else
          download_dir=options['download_dir']
        end
        FileUtils.mkdir_p(download_dir) unless File.exist?(download_dir)
        results.each {|result|
          timedout=0
          conn_refused=0
          if File.basename(result.download).include?('.torrent')
            basename= File.basename(result.download)
          else
            basename= rand(999999999).to_s + ".torrent"
          end
          File.open( File.join(download_dir, basename), 'wb' ) {|file| 
            file.write open(result.download.gsub("[", "%5B").gsub("]", "%5D")).read 
          } and Tget::Dlist.add( result.show + DLIST_SEP + result.ep_id )
        }
      end
    end
    def debug str
      puts str if @@options['debug']
    end
    def load_config
      config={}
      listing_shows=true
      config[:shows]=[]
      unless (file= (File.open(@@options['config_file'], 'r') rescue nil))
        unless @@options['silent_mode']
          puts "Could not open config file: \n#{@@options['config_file']}\nCheck permissions?\n\nWithout a config file, we have no shows to search for. Exiting..."
        end
        raise "Config file not found"
      end
      while( line=file.gets )
        if listing_shows==true
          (listing_shows=false and next) if line[/### Options ###/]
          config[:shows] << line.strip
          debug "Adding show '#{line.strip}'"
        else
          config[line[/^[^=]*/]]=line.gsub(/^[^=]*=/,'').strip
        end
      end
      file.close
      if @@options['debug']
        puts"Config:\n"
        pp config
        puts""
      end
      config
    end
  end
end
