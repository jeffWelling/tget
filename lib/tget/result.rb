module Tget
  #This class is to help turn abitrary data intto a dataset we can use
  #A Result object is created per result returned from the scrapers
  class Result
    def initialize(url, show, ep_id)
      @download_url=url
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
      "download_url=>#{@download_url}"
    end
  end
end
