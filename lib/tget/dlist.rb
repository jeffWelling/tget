module Tget
  class DList
    @@max_df=1024
    @@downloaded_files=[]
    class << self
      attr_reader :max_df
    end
    def self.load filename
      if( file=(File.open(File.expand_path(filename), 'r') rescue nil) )
        while( line=file.gets )
          next if line.strip.empty?
          @@downloaded_files << line.strip
        end
      end
      file.close rescue nil
      @@downloaded_files= @@downloaded_files.uniq.compact
    end
    def self.add event
      puts "DList.add()-ing #{event}"
      unless event.class==String
        raise ArgumentError, "Event is not a string"
      end
      @@downloaded_files << event

      while( @@downloaded_files.size > @@max_df )
        @@downloaded_files.delete_at(0)
      end
    end
    def self.has? title, id
      raise ArgumentError.new("DList.has?(title,id): id cannot be nil") if id.nil?
      @@downloaded_files || Tget::DList.load
      @@downloaded_files.each {|event|
        if (event[Regexp.new(title, 'i')] and event[Regexp.new(id, 'i')])
          puts "DList.has? has #{title}, #{id}, in #{event}"
          return true
        elsif (event[Regexp.new(title,'i')] and id.nil?)
          puts "DList.has? has #{title}, :empty, in #{event}"
          return true
        end
      }
      puts "DList.has? does not hass #{title}, #{id}"
      return false
    end
    def self.save file
      raise ArgumentError unless file.class==String
      while( @@downloaded_files.size > @@max_df )
        @@downloaded_files.delete_at(0)
      end
      File.open(file, 'w') {|f|
        @@downloaded_files.each {|event|
          f.write(event + "\n")
        }
      } rescue nil
    end
    def self.dump
      @@downloaded_files
    end
  end
end
