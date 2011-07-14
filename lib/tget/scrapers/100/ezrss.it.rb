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
        regex= Regexp.new( str.gsub(/[ \.]/,'[ \.]') )
        if torrent.title[regex]
          next if already_have?(str, get_uid(str))
          results << Tget::Result.new( torrent.link )
        end
      }
      results
    end
  end
end
