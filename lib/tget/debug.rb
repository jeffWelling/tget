module Debug
  def these_be_options o
    @@options=o
    @@out=@@options['logger']
  end
  def debug str
    (puts str if @@options['debug']) #rescue $stdout.puts(str)
  end
  def puts(*strings)
    @@out.puts(*strings) #rescue $stdout.puts(*strings)
  end
end
