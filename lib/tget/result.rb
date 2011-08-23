module Tget
  #This class is to help turn abitrary data intto a dataset we can use
  #A Result object is created per result returned from the scrapers
  class Result
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
        raise ArgumentError.new("Not ep_id: #{ep_id}")
      end
      if !url[/^http:\/\//].nil?
        #broken down for debugging
        pre=url.gsub(/[^\/]+$/,'')
        x=url.gsub('http://','')[/[^\/]+$/]
        post=URI.encode( x )
        @url= pre+post
      else
        @url= url
      end
      @show= show
      @ep_id= ep_id
    end
    attr_reader :show, :ep_id, :url
    def download
      @url
    end
    def inspect
      to_s
    end
    def to_s
      "Result Object:\nShow: #{@show}\nEpID: #{@ep_id}\nDownload URL: #{@url}"
    end
  end
end
