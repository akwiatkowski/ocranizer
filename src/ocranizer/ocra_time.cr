struct Ocranizer::OcraTime
  TYPE_ERROR    = -1
  TYPE_RELATIVE =  0
  TYPE_EXACT    =  1
  TYPE_FULLDAY  =  2
  TYPE_HOUR     =  3

  ZERO_SPAN    = Time::Span.new(0)
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

  # constructors, factories
  def self.new_error
    new(time: now_normalized, type: TYPE_ERROR)
  end

  def self.new_time_from
    new(time: now_normalized, type: TYPE_EXACT)
  end

  def self.new_time_to
    new(time: now_normalized + HOUR_SPAN, type: TYPE_EXACT)
  end

  def initialize(@time : Time, @type : Int32)
  end

  def self.parse_human(s : String)
    s = s.strip

    # parse human-like relative
    relative = parse_relative(s)

    # YYYY-mm-dd HH:MM
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d %H:%M", kind: Time::Kind::Local)
      return new(base_time: parsed, relative: relative, type: TYPE_EXACT)
    rescue Time::Format::Error
    end

    # YYYY-mm-dd, only day
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d", kind: Time::Kind::Local)
      return new(base_time: parsed, relative: relative, type: TYPE_FULLDAY)
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

      return new(base_time: parsed, relative: relative, type: TYPE_HOUR)
    rescue Time::Format::Error
    end

    return new(base_time: nil, relative: relative, type: TYPE_RELATIVE)
  end

  def self.new(base_time : (Time | Nil), relative : (Time::Span | Nil), type : Int32)
    if base_time.nil? && relative.nil?
      return new_error
    else
      t = base_time
      t = now_normalized if t.nil?

      r = relative
      r = ZERO_SPAN if r.nil?

      return new(time: add_relative_interval(t, r), type: type)
    end
  end

  # end of constructors

  # types
  def error?
    @type == TYPE_ERROR
  end

  def not_error?
    !error?
  end

  def self.parse_relative(s : String)
    is_okay = false
    t = Time::Span.new(0)

    if s =~ /next (\d*\s*\w+)/
      r = parse_relative_span($1)
      if r
        t += r
        is_okay = true
      end
    end

    if s =~ /prev (\d*\s*\w+)/
      r = parse_relative_span($1)
      if r
        t += (r * (-1))
        is_okay = true
      end
    end

    if is_okay
      return t
    else
      return nil
    end
  end

  def self.parse_relative_span(s : String) : (Time::Span | Nil)
    if s =~ /(\d*)\s*(\w+)/
      case $2
      when "now"
        return ZERO_SPAN
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

    return nil
  end

  def self.now_normalized
    e = Time.now.epoch
    e -= e % TEN_MIN_SPAN.total_seconds.to_i64
    e += TEN_MIN_SPAN.total_seconds.to_i64
    return Time.epoch(e)
  end

  def self.add_relative_interval(time : Time, span : Time::Span) : Time
    next_month = time.month
    next_year = time.year

    if span == MONTH_SPAN
      # it's tricky!
      # what if someone wants add month to January 30?
      next_month = time.month + 1
      if next_month > 12
        next_month = 1
        next_year = time.year + 1
      else
        next_year = time.year
      end

      begin
        result_time = Time.new(
          next_year,
          next_month,
          time.day,
          time.hour,
          time.minute
        )
        return result_time
      rescue e
        if e.message == "invalid time"
          return time + span
        else
          raise e
        end
      end
    end

    if span == YEAR_SPAN
    end

    return time + span
  end
end
