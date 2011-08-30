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
module Debug
  def these_be_options o
    @@options=o
    @@out=@@options['logger']
  end
  def debug str
    (puts str if @@options['debug']) #rescue $stdout.puts(str)
  end
  def puts(*strings)
    unless @@options['silent_mode']
      @@out.puts(*strings) #rescue $stdout.puts(*strings)
    end
  end
end
