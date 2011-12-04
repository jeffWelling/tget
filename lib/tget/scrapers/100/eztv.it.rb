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
  module Eztv
    @@url="http://eztv.it/"
    @@doc=Nokogiri::HTML(open(@@url))
    def search(str)
      results=[]
      #For each torrent listed on eztv.it ...
      @@doc.xpath('//table[6]').each {|a|
        regex= Regexp.new( str.gsub(/[ \.-]/,'[ \.-]') )
        #if it's one we want...
        if (a.children[6].children[2].children[1].children[0].to_s[regex] rescue false)
          debug "Matched #{str} to #{a.children[6].children[2].children[1].children[0].to_s[regex]}"
          title=str
          epid=EpisodeID.new(a.children[6].children[2].children[1].children[0].to_s, str)
          main_url=nil
          alt_urls=[]
          a.children[6].children[4].children.each do |b|
            if (b.attributes['class'].value[/\d$/] == '1' rescue false)
              main_url=b.attributes['href'].value
            elsif (b.attributes['class'].value[/magnet/] rescue false)
              next
            elsif (b.attributes['href'].value rescue false)
              alt_urls << b.attributes['href'].value
            end
          end
          if Tget::DList.has?(str, epid.to_s)
            debug "Skipped because we have it"
            next
          end
          Tget::DList.found str, ep_id.to_s
          results<< Result.new(main_url, title, epid)
        end
      }
      results
    end
  end
end
