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
  class DList
    class << self
      include Debug
      def max_df
        @max_df
      end
    end
    def self.load filename
      @max_df=1024
      @@downloaded_files=[]
      @@found_files=[]
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
      debug "DList.add()-ing #{event}"
      unless event.class==String
        raise ArgumentError, "Event is not a string"
      end
      if @@downloaded_files.include? event
        raise "DList.add(event): event already exists in downloaded_files"
      end

      @@downloaded_files << event

      while( @@downloaded_files.size > @max_df )
        @@downloaded_files.delete_at(0)
      end
    end
    def self.found event
      debug "DList.found() #{event}"
      unless event.class==String
        raise ArgumentError, "Event is not a string"
      end
      @@found_files << event
    end
    def self.has? title, id
      raise ArgumentError.new("DList.has?(title,id): id cannot be nil") if id.nil?
      @@downloaded_files || Tget::DList.load
      @@found_files||=[]
      @@downloaded_files.each {|event|
        if (event[Regexp.new(Regexp.escape(title), 'i')] and event[Regexp.new(Regexp.escape(id), 'i')])
          debug "DList.has? has #{title}, #{id}, in #{event} from downloaded_files"
          return true
        elsif (event[Regexp.new(title,'i')] and id.nil?)
          debug "DList.has? has #{title}, :empty, in #{event} from downloaded_files"
          return true
        end
      }
      @@found_files.each {|event|
        if (event[Regexp.new(Regexp.escape(title), 'i')] and event[Regexp.new(Regexp.escape(id), 'i')])
          debug "DList.has? has #{title}, #{id}, in #{event} from found_files"
          return true
        elsif (event[Regexp.new(title,'i')] and id.nil?)
          debug "DList.has? has #{title}, :empty, in #{event} from found_files"
          return true
        end
      }
      debug "DList.has? does not have #{title}, #{id}"
      return false
    end
    def self.save file
      raise ArgumentError unless file.class==String
      while( @@downloaded_files.size > @max_df )
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
