module Tget
  class Main
    MAX_PRIO=255
    def initialize options={}
      @options=options
      @scrapers={}
      @out= options['logger'] || nil    
      load_scrapers options
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
      results=[]
      Dir.chdir( @options['working_dir'] ) do |working_dir|
        debug "Debugging output enabled"
        #load config
        config=load_config

        MAX_PRIO.times {|i|
          if @scrapers.has_key? i
            #This allows multiple scrapers within the same priority
            #but does not guarantee an order for said scrapers.
            @scrapers[i].each {|scraper|
              debug "Working with #{scraper.gsub(/(\.(.){2,3}){1,2}$/,'')}"

              extend Tget.const_get(scraper.gsub(/(\.(.){2,3}){1,2}$/,''))
              config[:shows].each {|show|
                retries=0
                debug "Searching #{scraper.gsub(/(\.(.){2,3}){1,2}$/,'')} for #{show}..."
                begin
                  r=search(show)
                rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, Errno::EHOSTUNREACH 
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
        if @options['debug']
          results.each {|result|
            puts result
          }
        end

        #download file
        if @options['download_dir'][/\/$/].nil?
          download_dir=@options['download_dir'] + '/'
        else
          download_dir=@options['download_dir']
        end
        FileUtils.mkdir_p(download_dir) unless File.exist?(download_dir)
        results.each {|result|
          retries=0
          if File.basename(result.download).include?('.torrent')
            basename= File.basename(result.download)
          else
            basename= rand(999999999).to_s + ".torrent"
          end
          begin
            File.open( File.join(download_dir, basename), 'wb' ) {|file| 
              file.write open(result.download.gsub("[", "%5B").gsub("]", "%5D")).read 
            } and Tget::Dlist.add( result.show + DLIST_SEP + result.ep_id )
          rescue OpenURI::HTTPError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, Errno::EHOSTUNREACH 
            next if retries > MAX_RETRIES
            debug "Connection failed, trying again... (Attempt ##{retries+1})"
            retries+=1
            retry
          end
        }
      end
      results
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
        config.each_key {|key|
          if key==:shows
            puts "   Shows: --|"
            config[:shows].each {|show|
              puts "            #{show}"
            }
          else
            puts "   "+key
            puts "       "+config[key]
          end
        }
      end
      config
    end
    def puts(*strings)
      @out.puts(*strings) 
    end
  end
end
