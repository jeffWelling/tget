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
    class ShowReqd < ArgumentError; end
    include Debug
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
        @episode_id= "#{raw_ep_id[AIRDATE_REGEX][/^(\d){4}/]}-#{raw_ep_id[AIRDATE_REGEX][/[ \.-](\d){1,2}[ \.-]/].gsub(/[ \.-]/,'')}-#{raw_ep_id[AIRDATE_REGEX][/(\d){1,3}$/]}"

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
