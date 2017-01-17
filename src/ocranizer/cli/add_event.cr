require "colorize"

class Ocranizer::Cli::AddEvent
  def initialize
    @event = Ocranizer::Event.new
  end

  def store
  end

  def get_data
    e = Ocranizer::Event.new

    get_time_from
  end

  def get_time_from
    puts "Time from? "
    s = gets
    r = process_time(s.to_s)

    unless r[:type] == :error
      puts "Time from: #{r[:time].colorize(:green)}"
    end
  end

  def process_time(s : String)
    s = s.strip

    # YYYY-mm-dd HH:MM
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d %H:%M", kind: Time::Kind::Local)
      return {time: parsed, type: :exact}
    rescue Time::Format::Error
    end

    # YYYY-mm-dd, only day
    begin
      parsed = Time.parse(time: s, pattern: "%Y-%m-%d", kind: Time::Kind::Local)
      return {time: parsed, type: :full_day}
    rescue Time::Format::Error
    end

    # HH:MM, only hour
    begin
      parsed = Time.parse(time: s, pattern: "%H:%M", kind: Time::Kind::Local)
      t = Time.new(
        year: Time.now.year,
        month: Time.now.month,
        day: Time.now.day,
        hour: parsed.hour,
        minute: parsed.minute
      )

      # not allow adding old events
      if t < Time.now
        t += Time::Span.new(24)
      end

      return {time: t, type: :only_hour}
    rescue Time::Format::Error
    end

    return {time: Time.now, type: :error}
  end
end
