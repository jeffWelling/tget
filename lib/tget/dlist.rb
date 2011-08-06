module Tget
  class DList
    MAX_DF=1024
    def initialize filename
      @@downloaded_files=[]
      if( file=(File.open(filename, 'r') rescue nil) )
        while( line=file.gets )
          @@downloaded_files << line
        end
      end
      file.close rescue nil
    end
    def self.add event
      unless event.class==String
        raise ArgumentError, "Event is not a string"
      end
      @@downloaded_files << event

      while( @@downloaded_files.size > MAX_DF )
        @@downloaded_files.delete_at(0)
      end
    end
    def self.has? title, id
      @@downloaded_files.each {|event|
        if (event[Regexp.new(title, 'i')] and event[Regexp.new(id, 'i')])
          return true
        end
      }
      return false
    end
    def self.save file
      raise ArgumentError unless file.class==String
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
