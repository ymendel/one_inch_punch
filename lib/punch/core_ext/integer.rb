class Integer
  def elapsed_time
    minutes, seconds = divmod(60)
    hours, minutes   = minutes.divmod(60)

    seconds = '%02d' % seconds
    minutes = '%02d' % minutes

    time = "#{minutes}:#{seconds}"
    time = "#{hours}:#{time}" unless hours.zero?
    time
  end
end
