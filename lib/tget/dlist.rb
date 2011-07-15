module Tget
  class DList
    MAX_DF=1024
    def initialize filename
      @@downloaded_files=[]
      if( file=(File.open(options['downloaded_files'], 'r') rescue nil) )
        while( line=file.gets )
          if is_formatted?(line)
            @@downloaded_files << line
          end
        end
      end
      file.close rescue nil
    end
    def self.add event
      puts "DList.add '#{event}'"
      unless (event.class==String and is_formatted?(event))
        raise ArgumentError
      end
      @@downloaded_files << event

      while( @@downloaded_files.size > MAX_DF )
        @@downloaded_files.delete_at(0)
      end
    end
    def self.has? title, id
      puts "DList.has?(\"#{title}\", \"#{id}\""
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
          f.write(event)
        }
      } rescue nil
    end

    private
    def self.is_formatted? line
      begin
        if ((line.split('-').length == 2) and (line.split('-')[1][/s(\d){1,2}e(\d){1,2}/i] || 
                                               line.split('-')[1][/(\d){4}\s(\d){1,2}\s(\d){1,2}/i] ))
            return true
        end
      rescue
        return false
      end
    end
  end
end
