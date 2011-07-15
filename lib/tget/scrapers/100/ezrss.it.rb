require 'rss'
require 'open-uri'
module Tget
  module Ezrss
    RSS_FEED="http://ezrss.it/feed/"
    def search(str)
      rss_content=''
      results=[]
      open(RSS_FEED) do |f|
        rss_content= f.read
      end
      rss= RSS::Parser.parse(rss_content, false)
      rss.items.each {|torrent|
        regex= Regexp.new( str.gsub(/[ \.-]/,'[ \.-]') )
        if torrent.title[regex]
          debug "Matched #{str} to #{torrent.title}"
          (debug "Skipped because we has it" and next) if Tget::DList.has?(str, get_uid(str, torrent.title))
          results << Tget::Result.new( torrent.link, str, get_uid(str, torrent.title) )
        else
          debug "Could not not match #{str} to #{torrent.title}"
        end
      }
      results
    end
  end
end
