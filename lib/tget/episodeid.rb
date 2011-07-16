AIRDATE_REGEX=/(\d){4}[ \.-](\d){1,2}[ \.-](\d){1,2}/
module Tget
  #This is a class to assist in normalizing episode IDs
  #The normalized episode ID format is 'S03E20', or '2007-04-20'
  #for episodes wich have an air date instead of an episode ID.
  #This object should be able to take any episode format and 
  class EpisodeID
    def initialize raw_ep_id, show
      @original=raw_ep_id
      if raw_ep_id[AIRDATE_REGEX]
        @episode_id= "#{raw_ep_id[AIRDATE_REGEX][/^(\d){4}/]}-#{raw_ep_id[AIRDATE_REGEX][/-(\d){1,2}-/].gsub('-','')}-#{raw_ep_id[AIRDATE_REGEX][/(\d){1,3}$/]}"

      elsif raw_ep_id[/s(\d){1,2}e(\d){1,3}/i]
        @episode_id=raw_ep_id[/s(\d){1,2}e(\d){1,3}/i].gsub(/s/i,'s').gsub(/e/i,'e')

      elsif raw_ep_id[/\s(\d){1,2}(x)(\d){1,3}/i]
        @episode_id= "s#{raw_ep_id[/\s(\d){1,2}(x)(\d){1,3}/i].strip[/^(\d){1,2}/]}e#{raw_ep_id[/\s(\d){1,2}(x)(\d){1,3}/i].strip[/(\d){1,3}$/]}"
      else
        #Could get here for something like
        #"National Geographic The Perils Of Religion", which is a valid episode 
        #but has no valid episode ID or air date.
        @episode_id= raw_ep_id.gsub(show,'').gsub(/\[[^\[]+\]/,'')
      end
    end
    def id
      @episode_id
    end
    def original
      @original
    end
    def to_s
      @episode_id
    end
  end
end
