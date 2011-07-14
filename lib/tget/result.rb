module Tget
  class Result
    def initialize(url=nil)
      @download_url=url
    end
    def download
      @download_url
    end
    def inspect
    "download_url=>#{@download_url}"
    end
  end
end
