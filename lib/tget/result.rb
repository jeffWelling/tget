module Tget
  #This class is to help turn abitrary data intto a dataset we can use
  #A Result object is created per result returned from the scrapers
  class Result
    def initialize(url, show, ep_id)
      if !url[/^http:\/\//].nil?
        #broken down for debugging
        pre=url.gsub(/[^\/]+$/,'')
        x=url.gsub('http://','')[/[^\/]+$/]
        post=URI.encode( x )
        @download_url= pre+post
      else
        @download_url= url
      end
      @show= show
      @ep_id= ep_id
    end
    def show
      @show
    end
    def ep_id
      @ep_id
    end
    def download
      @download_url
    end
    def inspect
      to_s
    end
    def to_s
      "Result Object:\nShow: #{@show}\nEpID: #{@ep_id}\nDownload URL: #{@download_url}"
    end
  end
end
