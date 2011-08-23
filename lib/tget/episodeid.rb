AIRDATE_REGEX=/(\d){4}[ \.-](\d){1,2}[ \.-](\d){1,2}/
#1x23
FORMAT0=/s(\d){1,2}e(\d){1,3}/i
FORMAT1=/\s?(\d){1,2}(x)(\d){1,3}/i
module Tget
  #This is a class to assist in normalizing episode IDs
  #The normalized episode ID format is 'S03E20', or '2007-04-20'
  #for episodes wich have an air date instead of an episode ID.
  #This object should be able to take any episode format and
  #standardize ones that are foreign or unsightly.
  class EpisodeID
    class ShowReqd < ArgumentError
    end
    #the show argument is required in order to properly
    #match, for example, National Geographic episode names
    def initialize raw_ep_id, show=nil
      @original=raw_ep_id
      @show=show
      set_epid raw_ep_id
    end
    def id
      @episode_id
    end
    def name
      @episode_name
    end
    def original
      @original
    end
    def to_s
      @episode_id or @episode_name
    end
    def set_epid raw_ep_id
      if raw_ep_id[AIRDATE_REGEX]
        @episode_id= "#{raw_ep_id[AIRDATE_REGEX][/^(\d){4}/]}-#{raw_ep_id[AIRDATE_REGEX][/-(\d){1,2}-/].gsub('-','')}-#{raw_ep_id[AIRDATE_REGEX][/(\d){1,3}$/]}"

      elsif raw_ep_id[FORMAT0]
        @episode_id=raw_ep_id[FORMAT0].gsub(/s/i,'s').gsub(/e/i,'e')

      elsif raw_ep_id[FORMAT1]
        @episode_id= "s#{raw_ep_id[FORMAT1].strip[/^(\d){1,2}/]}e#{raw_ep_id[FORMAT1].strip[/(\d){1,3}$/]}"
      elsif  (named?(raw_ep_id) rescue false)
        #Could get here for something like
        #"National Geographic The Perils Of Religion", which is a valid episode 
        #but has no valid episode ID or air date.
        @episode_name= raw_ep_id.gsub(@show,'').gsub(/\[[^\[]+\].*$/,'').gsub(/^\s?-?\s?/,'').gsub(/\s?-?\s?$/,'')
      else
        raise ArgumentError.new("EpisodeID could not determind id from: #{raw_ep_id}")
      end
    end
    def named? str
      raise ShowReqd.new('Could not access @show') if @show.nil?
      !str.gsub(@show,'').gsub(/\[[^\[]+\].*$/,'').gsub(/^\s?-?\s?/,'').gsub(/\s?-?\s?$/,'').nil? rescue false
    end
  end
end
