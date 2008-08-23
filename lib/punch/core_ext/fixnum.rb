class Fixnum
  def elapsed_time
    tmp = divmod(60)
    seconds = '%02d' % tmp.last
    tmp = tmp.first.divmod(60)
    minutes = '%02d' % tmp.last
    hours   = tmp.first
    
    time = "#{minutes}:#{seconds}"
    time = "#{hours}:#{time}" unless hours == 0
    time
  end
end
