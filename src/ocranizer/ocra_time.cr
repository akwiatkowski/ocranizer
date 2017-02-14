require "yaml"

require "./ocra_time_span"

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

  JSON.mapping(
    type: Int32 | Nil,
    time: Time
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

    # parse like `next year` human strings
    relative_span = Ocranizer::OcraTimeSpan.new(string: s)

    # YYYY-mm-dd HH:MM
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d %H:%M", kind: Time::Kind::Local)
      parsed += relative_span
      return new(time: parsed, type: TYPE_EXACT)
    rescue Time::Format::Error
    end

    # YYYY-mm-dd, only day
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d", kind: Time::Kind::Local)
      parsed += relative_span
      return new(time: parsed, type: TYPE_FULLDAY)
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
        parsed = Ocranizer::OcraTimeSpan.modify_years(time: parsed, quantity: 1)
      end
      return new(time: parsed, type: TYPE_FULLDAY)
    rescue Time::Format::Error
    end

    # HH:MM, only hour
    begin
      year = Time.now.year
      month = Time.now.month
      day = Time.now.day

      if base_time
        year = base_time.year
        month = base_time.month
        day = base_time.day
      end

      parsed = Time.parse(time: s, pattern: "%H:%M", kind: Time::Kind::Local)
      parsed = Time.new(
        year: year,
        month: month,
        day: day,
        hour: parsed.hour,
        minute: parsed.minute,
        kind: Time::Kind::Local
      )
      parsed += relative_span
      return new(time: parsed, type: TYPE_HOUR)
    rescue Time::Format::Error
    end

    if relative_span.error?
      return new_error
    else
      base_time = now_normalized if base_time.nil?
      base_time += relative_span
      return new(time: base_time, type: TYPE_RELATIVE)
    end
  end

  # end of constructors

  # types
  def error?
    @type == TYPE_ERROR
  end

  def fullday?
    @type == TYPE_FULLDAY
  end

  def relative?
    @type == TYPE_RELATIVE
  end

  def not_error?
    !error?
  end

  def not_fullday?
    !fullday?
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
    return at_beginning_of_day if fullday?
    return @time
  end

  def at_end
    return at_end_of_day if fullday?
    return @time
  end

  def >(other)
    return self.time > other.time
  end

  def <(other)
    return self.time < other.time
  end

  def self.now
    return Time.now.to_local
  end

  def self.now_normalized
    e = Time.now.to_local.epoch
    e -= e % TEN_MIN_SPAN.total_seconds.to_i64
    e += TEN_MIN_SPAN.total_seconds.to_i64
    return Time.epoch(e).to_local
  end
end
