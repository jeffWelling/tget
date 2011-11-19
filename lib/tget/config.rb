module Tget
  class Config
    class << self
      include Debug
    end
    def self.load_config options= Tget::Main.default_opts
      config={}
      listing_shows=true
      config[:shows]=[]
      unless (file= (File.open(options['config_file'], 'r') rescue nil))
        unless options['silent_mode']
          puts "Could not open config file: \n#{options['config_file']}\nCheck permissions?\n\nWithout a config file, we have no shows to search for. Exiting..."
        end
        debug "No config file exists"
        return false
      end
      while( line=file.gets )
        if listing_shows==true
          if line[Regexp.new(CONFIG_DELIM)]
            listing_shows=false
            next
            debug "Entering config options section"
          end
          next if line.strip.empty?
          config[:shows] << line.strip
          debug "Adding show '#{line.strip}'"
        else
          config[line[/^[^=]*/]]=line.gsub(/^[^=]*=/,'').strip
        end
      end
      file.close
      if options['debug']
        puts"Config:  \n"
        print_config( config )
      end
      config
    end
    def self.save_config config, path=File.expand_path("~/.tget_cfg")
      raise "save_opts() was passed invalid options" unless verify_opts(config)  
      File.open( path, 'w' ) do |f|
        config[:shows].each do |show|
          f.puts show
        end
        f.puts "### Options ###"
        config.each_key do |key|
          next if key == :shows
          f.puts(key + "=" + config[key])
        end
      end
    end
    def self.del_show show, options= Tget::Main.default_opts
      show="#{show}"
      raise "del_show(show): show must be a String" unless show.class==String
      config=load_config options
      config[:shows].delete show
      save_config config, options['config_file']
    end
    def self.add_show show, options= Tget::Main.default_opts
      show="#{show}"
      return(false) if show.empty?
      config=load_config(options)
      config[:shows] << show
      save_config(config, options['config_file'])
    end
    def self.print_config config
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

    def self.verify_opts config
      begin
        false unless (config.class==Hash ||
                     config.has_key?(:shows) ||
                     config[:shows].class==Array)
      rescue
        return false
      end
      true
    end
  end
end
