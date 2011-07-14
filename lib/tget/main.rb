module Tget
  class Main
    SCRAPERS={}
    MAX_PRIO=255
    # {100=>{piratebay},
    #  102=>{eztv}}
    def initialize
      MAX_PRIO.times {|i|
        Find.find( File.join(File.expand_path(File.dirname(__FILE__)), "scrapers/#{i}/")) {|s|
          next unless s[/\.rb$/]
          #puts "Loading #{s}"
          load s
          SCRAPERS[i]=[] unless SCRAPERS.has_key? i
          SCRAPERS[i] << File.basename(s).capitalize
        }
      }
    end
    def run(options)
      puts "Debugging output enabled" if options['debug']
      #load config
      listing_shows=true
      shows=[]
      config={}
      results=[]
      unless (file= (File.open(options['config_file'], 'r') rescue nil))
        unless options['silent_mode']
          puts "Could not open config file: \n#{options['config_file']}\nCheck permissions?\n\nWithout a config file, we have no shows to search for. Exiting..."
        end
        exit
      end
      while( line=file.gets )
        if listing_shows==true
          (listing_shows=false and next) if line[/### Options ###/]
          shows << line
          puts "Adding show '#{line.strip}'" if options['debug']
        else
          config[line[/^[^=]*/]]=line.gsub(/^[^=]*=/,'').strip
        end
      end
      file.close
      if options['debug']
        puts"Config:\n"
        pp config
        puts""
      end

      #call SCRAPERS
      MAX_PRIO.times {|i|
        if SCRAPERS.has_key? i
          #This allows multiple scrapers within the same priority
          #but does not guarantee an order for said scrapers.
          SCRAPERS[i].each {|scraper|
            puts "scraper"
            pp scraper.gsub(/(\.(.){2,3}){1,2}$/,'')
            extend Tget.const_get(scraper.gsub(/(\.(.){2,3}){1,2}$/,''))
            shows.each {|show|
              results << search(show)
            }
          }
        end
      }
      results=results.compact

      puts "Results:"
      pp results

      #download file
      if options['download_dir'][/\/$/].nil?
        download_dir=options['download_dir'] + '/'
      else
        download_dir=options['download_dir']
      end
      FileUtils.mkdir_p(download_dir) unless File.exist?(download_dir)
      results.each {|result|
        domain=result.download[/^(http:\/\/)?[^\/]*\//].gsub(/http:\/\//i,'').gsub(/\/$/,'')
        puts "Connecting to #{domain} to download:\n#{result.download}" if options['debug']
        Net::HTTP.start( domain ) {|http|
          resp= http.get( result.download.gsub(/^(http:\/\/)?[^\/]*\//i,'') )
          puts `pwd`
          puts Dir.pwd
          open( download_dir + File.basename(result.download), 'wb' ) {|file|
            file.write(resp.body)
          }
        }
      }
    end
  end
end
