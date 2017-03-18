struct Time
  def to_s_day
    to_s("%Y-%m-%d")
  end

  def to_s_day_safe
    to_s("%Y%m%d")
  end
end
