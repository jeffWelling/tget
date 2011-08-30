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
require 'rss'
module Tget
  module Btchat
    @@rss_feed="http://rss.bt-chat.com/?cat=9"
    def search(str)
      rss_content=''
      results=[]
      open(@@rss_feed) do |f|
        rss_content= f.read
      end
      rss= RSS::Parser.parse(rss_content, false)
      rss.items.each {|torrent|
        regex= Regexp.new( str.gsub(/[ \.-]/,'[ \.-]') )
        if torrent.title[regex]
          ep_id=EpisodeID.new(torrent.title, str)
          debug "Matched #{str} to #{torrent.title}"
          debug "epid is #{ep_id.to_s}"
          if Tget::DList.has?(str, ep_id.to_s)
            debug "Skipped because we has it"
            next
          end
          results << Tget::Result.new( torrent.link, str,  ep_id )
        else
          debug "Could not not match #{str} to #{torrent.title}"
        end
      }
      results
    end
  end
end
