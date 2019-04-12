def get_timestamp(params = {})
  stamp = ''
  [:minute, :hour, :date, :month, :weekday].each do |k|
    stamp << "#{params[k] || '*'} "
  end
  stamp.strip
end
