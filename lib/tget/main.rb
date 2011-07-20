module Tget
  class Main
    SCRAPERS={}
    MAX_PRIO=255
    # {100=>{piratebay},
    #  102=>{eztv}}
    def initialize
      @@options={}
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
      @@options=options
      debug "Debugging output enabled"
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
          shows << line.strip
          debug "Adding show '#{line.strip}'"
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
            debug "Working with #{scraper.gsub(/(\.(.){2,3}){1,2}$/,'')}"

            extend Tget.const_get(scraper.gsub(/(\.(.){2,3}){1,2}$/,''))
            shows.each {|show|
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
        File.open( File.join(download_dir, basename), 'wb' ) {|file| file.write open(result.download.gsub("[", "%5B").gsub("]", "%5D")).read }
=begin
        domain=result.download[/^(http:\/\/)?[^\/]*\//].gsub(/http:\/\//i,'').gsub(/\/$/,'')
        begin
          debug "Connecting to #{domain} to download:\n#{result.download}"
          Net::HTTP.start( domain ) {|http|
            puts url=result.download.gsub(/^(http:\/\/)?[^\/]*\//i,'')
            url=url.gsub("[", "%5B").gsub("]", "%5D")
            puts url
            resp= http.get( result.download.gsub(/^(http:\/\/)?[^\/]*\//i,'') )
            if resp.to_s.gsub(/bad request/i,'')
              debug "Download failed -- bad request, retrying..."
              resp=http.get(url)
              debug "Download failed again...." if resp.to_s.gsub(/bad request/i,'')
            end
            if File.basename(result.download).include?('.torrent')
              basename= File.basename(result.download)
            else
              basename= rand(999999999).to_s + ".torrent"
            end
            open( download_dir + basename, 'wb' ) {|file|
              if file.write(resp.body)
                debug "Saved #{basename}." 
                Tget::DList.add "#{result.show} #{DLIST_SEP} #{result.ep_id}"
              end
            }
          }
        rescue Errno::ECONNREFUSED => e
          next if conn_refused >= MAX_RETRIES
          debug "Connection Refused, retrying (#{conn_refused+1})..."
          conn_refused+=1
          retry
        rescue Errno::ECONNRESET, Errno::ETIMEDOUT => e
          next if timedout >= MAX_RETRIES
          debug "Connection Reset/Timed out, retrying (#{timedout+1})..."
          timedout+=1
          retry
        end
=end
      }
    end
    def debug str
      puts str if @@options['debug']
    end
  end
end