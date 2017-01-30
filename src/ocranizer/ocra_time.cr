require "yaml"

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

  YAML.mapping(
    type: {
      type:    Int32,
      nilable: true,
    },
    time: {
      type:    Time,
      nilable: false,
    }
  )

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
    @time = @time.to_local
  end

  def self.parse_human(string : String, base_time : (Time | Nil) = nil)
    s = string.strip

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

    # mm-dd, only day for current year
    # NOTE: enforce time > now
    begin
      parsed = Time.parse(time: s, pattern: "%m-%d", kind: Time::Kind::Local)
      parsed = Time.new(
        year: Time.now.year,
        month: parsed.month,
        day: parsed.day,
        hour: parsed.hour,
        minute: parsed.minute,
        kind: Time::Kind::Local
      )
      if parsed < Time.now
        # add 1 year because time cannot be in past
        parsed = add_relative_interval(time: parsed, span: YEAR_SPAN)
      end

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
        minute: parsed.minute,
        kind: Time::Kind::Local
      )

      return new(base_time: parsed, relative: relative, type: TYPE_HOUR)
    rescue Time::Format::Error
    end

    return new(base_time: base_time, relative: relative, type: TYPE_RELATIVE)
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

  def full_day?
    @type == TYPE_FULLDAY
  end

  def not_error?
    !error?
  end

  # human type
  def to_human
    case @type
    when TYPE_RELATIVE then to_full_string
    when TYPE_EXACT    then to_full_string
    when TYPE_FULLDAY  then to_date_string
    when TYPE_HOUR     then to_full_string
    else                    "Error"
    end
  end

  def to_full_string
    return to_date_string + " " + to_hour_string
  end

  def to_date_string
    return @time.to_s("%Y-%m-%d")
  end

  def to_hour_string
    return @time.to_s("%H:%M")
  end

  def at_beginning_of_day
    time.at_beginning_of_day
  end

  def at_end_of_day
    time.at_end_of_day
  end

  def at_beginning
    return at_beginning_of_day if full_day?
    return @time
  end

  def at_end
    return at_end_of_day if full_day?
    return @time
  end

  def >(other)
    return self.time > other.time
  end

  def <(other)
    return self.time < other.time
  end

  # parsing code
  def self.parse_relative(s : String)
    is_okay = false
    t = Time::Span.new(0)
    regexp = /(next|prev)?\s*(\d*\s*\w+)/
    result = s.scan(regexp)

    # protip: better use scan, becuase if there is nil at $1
    # you wil have problem to debug it
    if result.size > 0
      r = parse_relative_span(result[0][2])

      if r
        if result[0][1]?.to_s.strip == "prev"
          t += (r * (-1))
          is_okay = true
        else
          t += r
          is_okay = true
        end
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
      begin
        result_time = Time.new(
          time.year + 1,
          time.month,
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

    return time + span
  end
end
