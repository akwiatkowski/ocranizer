struct Ocranizer::OcraTime
  TYPE_EXACT = 1
  TYPE_FULLDAY = 2
  TYPE_HOUR = 3

  @type : (Int32 | Nil)
  getter :type
  getter :time

  def initialize(@time : Time)
  end

  def initialize(@time : Time, @type : Int32)
  end

  def self.parse_relative(s : String)
    if s =~ /next (\w+)/
      s = parse_relative_span($1)
      return s
    end

    if s =~ /prev (\w+)/
      s = parse_relative_span($1) * -1
      return s
    end
  end

  def self.parse_relative_span(s : String)
    
    if s =~ /(\d*)\s*(\w+)/
      case $2
      when "hour"
        return Time::Span.new(1)
      when "hours"
        return Time::Span.new(1) * $1.to_s.to_i
      when "day"
        return Time::Span.new(24)
      when "days"
        return Time::Span.new(24) * $1.to_s.to_i

        puts $1, $2
    end
    return 1
  end

  def self.parse_human(s : String)
    s = s.strip

    # parse human-like relative
    parse_relative(s)

    # YYYY-mm-dd HH:MM
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d %H:%M", kind: Time::Kind::Local)
      return new(time: parsed, type: TYPE_EXACT)
    rescue Time::Format::Error
    end

    # YYYY-mm-dd, only day
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d", kind: Time::Kind::Local)
      return new(time: parsed, type: TYPE_FULLDAY)
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

      return new(time: parsed, type: TYPE_HOUR)
    rescue Time::Format::Error
    end

    # raise Time::Format::Error
  end
end
