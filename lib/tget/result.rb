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
  #This class is to help turn abitrary data intto a dataset we can use
  #A Result object is created per result returned from the scrapers
  class Result
    include Debug
    def is_ep_id? ep_id
      return true if ep_id.class== Tget::EpisodeID
      false
    end
    def initialize(url, show, ep_id)
      raise ArgumentError unless (!url.nil? and !show.nil? and !ep_id.nil?)
      if ep_id.class==String
        ep_id=Tget::EpisodeID.new(ep_id)
      end
      unless is_ep_id? ep_id
        raise ArgumentError.new("Result.new(,,x): x must be Tget::EpisodeID")
      end
      if !url[/^http:\/\//].nil?
        #broken down for debugging
        pre=url.gsub(/[^\/]+$/,'')
        x=url.gsub('http://','')[/[^\/]+$/]
        post=encode( x )
        @url= pre+post
      else
        @url= url
      end
      @show= show
      @ep_id= ep_id
      @alt_urls=[]
    end
    attr_reader :show, :ep_id, :url, :alt_urls
    def add_alt_urls x
      raise ArgumentError.new('add_alt_urls() only takes arrays') unless x.class==Array
      @alt_urls= (@alt_urls+x).flatten.uniq
    end
    def download
      @url
    end
    def inspect
      to_s
    end
    def to_s
      o="Result Object:\nShow: #{@show}\nEpID: #{@ep_id}\nDownload URL: #{@url}"
      @alt_urls.each {|alt_url|
        o+="\nAlt DL URL: #{alt_url}"
      }
      o
    end
    private
    #FIXME
    #Documentation that I read online said I should be able to accomplish
    #this with URI.encode(str) but I tried that and it wasn't properly
    #encoding [ and ], so I wrote an encode() method until I can figure
    #out why.
    def encode str
      str.gsub("[", "%5B").gsub("]", "%5D")
    end
  end
end
