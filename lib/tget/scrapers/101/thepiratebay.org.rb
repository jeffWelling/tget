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
  module Thepiratebay
    #Now, I scoured Thepiratebay.org for a good fifteen minutes looking
    #for anything that indicates one way or another what their position
    #is regarding screen-scraping their website, but I have to provide a
    #false User Agent to get Nokogiri to load the page. It could be a bug,
    #it could be intentional, but without knowing either way I'm going
    #to assume it's fine until I hear otherwise. I checked out their RSS
    #feeds, but you can't search via RSS nor do they provide a feed for
    #the top torrents in a category - the feeds provided are of the most
    #recent uploads to that category. Allons-y!
    @@u_a="Mozilla/5.0 (X11; Linux i686; rv:6.0) Gecko/20100101 Firefox/6.0"
    def search(str)
      doc=_search(str)
      results=[]
      pre_results={}
      #For each torrent in the search results...
      doc.xpath('//tr').each {|a|
        begin
          title=a.children[2].children[1].children[0].children[0].text
          url=a.children[2].children[3].attributes['href'].value
          seeds=a.children[4].children[0].text
        rescue
          next
        end
        epid=EpisodeID.new(title,str)
        result=Result.new(url,str,epid)
        def result.seeds= s
          @seeds=s
        end
        def result.seeds
          @seeds
        end
        result.seeds= seeds
        pre_results[str+epid.to_s]||=[]
        if seeds.to_i >= @options['min_seeds']
          pre_results[str+epid.to_s] << result
        end
      }
      pre_results.each_key {|key|
        unless pre_results[key].empty?
          debug "For each of result identified by '#{key}'..."
          pre_results[key]=pre_results[key].sort
          pre_results[key].each {|r|
            debug r.seeds+" seeds"
          }
          begin
            puts "Current preresults..."
            pp pre_results[key]
            debug "We will use the one with #{pre_results[key][-1].seeds} seeds"
            if Tget::DList.has?(str,pre_results[key][-1].ep_id.to_s)
              debug "Skipped because we have it"
              next
            end
            Tget::DList.found( str,pre_results[key][-1].ep_id.to_s )
          rescue
            puts "FAILED preresults"
            pp pre_results[key]
            raise
          end
          results<<pre_results[key].sort[0]
        end
      }
      results
    end

    private
    def _search str
      page="http://www.thepiratebay.org/search/#{URI.encode(str)}/0/3/0"
      Nokogiri::HTML(open(page,'User-Agent'=>@@u_a))
    end
  end
end
