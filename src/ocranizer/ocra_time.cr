struct Ocranizer::OcraTime
  TYPE_RELATIVE = 0
  TYPE_EXACT    = 1
  TYPE_FULLDAY  = 2
  TYPE_HOUR     = 3

  TEN_MIN_SPAN = Time::Span.new(0, 10, 0)
  HOUR_SPAN    = Time::Span.new(1, 0, 0)
  DAY_SPAN     = HOUR_SPAN * 24
  WEEK_SPAN    = DAY_SPAN * 7
  # above will require some hacks
  MONTH_SPAN = DAY_SPAN * 30
  YEAR_SPAN  = DAY_SPAN * 365

  @type : (Int32 | Nil)
  getter :type
  getter :time

  def initialize(@time : Time)
  end

  def initialize(@time : Time, @type : Int32)
  end

  def self.parse_relative(s : String)
    t = Time::Span.new(0)

    if s =~ /next (\w+)/
      t += parse_relative_span($1)
    end

    if s =~ /prev (\w+)/
      u = parse_relative_span($1)
      t += (u * (-1)) if u
    end

    return t
  end

  def self.parse_relative_span(s : String) : Time::Span
    if s =~ /(\d*)\s*(\w+)/
      case $2
      when "hour"
        return HOUR_SPAN
      when "hours"
        return HOUR_SPAN * $1.to_s.to_i
      when "day"
        return DAY_SPAN
      when "days"
        return DAY_SPAN * $1.to_s.to_i
      when "week"
        return WEEK_SPAN
      when "weeks"
        return WEEK_SPAN * $1.to_s.to_i
      when "month"
        return MONTH_SPAN
      when "months"
        return MONTH_SPAN * $1.to_s.to_i
      when "year"
        return YEAR_SPAN
      when "years"
        return YEAR_SPAN * $1.to_s.to_i
      end
    end

    return Time::Span.new(0)
  end

  def self.parse_human(s : String)
    s = s.strip

    # parse human-like relative
    relative = parse_relative(s)

    # YYYY-mm-dd HH:MM
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d %H:%M", kind: Time::Kind::Local)
      return new(time: parsed + relative, type: TYPE_EXACT)
    rescue Time::Format::Error
    end

    # YYYY-mm-dd, only day
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d", kind: Time::Kind::Local)
      return new(time: parsed + relative, type: TYPE_FULLDAY)
    rescue Time::Format::Error
    end

    # HH:MM, only hour
    begin
      parsed = Time.parse(time: s, pattern: "%H:%M", kind: Time::Kind::Local)
      parsed = Time.new(
        year: Time.now.year,
        month: Time.now.month,
        day: Time.now.day,
        hour: parsed.hour,
        minute: parsed.minute
      )

      return new(time: parsed + relative, type: TYPE_HOUR)
    rescue Time::Format::Error
    end

    return new(time: now_normalized + relative, type: TYPE_RELATIVE)
  end

  def self.now_normalized
    e = Time.now.epoch
    e -= e % TEN_MIN_SPAN.total_seconds.to_i64
    e += TEN_MIN_SPAN.total_seconds.to_i64
    return Time.epoch(e)
  end
end
