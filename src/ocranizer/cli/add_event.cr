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
    get_time_to
  end

  def get_time_from
    loop do
      puts "Time from? "
      s = gets
      r = OcraTime.parse_human(s.to_s)

      if r.not_error?
        puts "Time from: #{r.time.to_s.colorize(:green)}"
        @event.time_from = r
        return
      end
    end
  end

  def get_time_to
    loop do
      puts "Time to? (enter to add +1h)"
      s = gets
      r = OcraTime.parse_human(string: s.to_s, base_time: @event.time_from.time)

      if r.not_error?
        puts "Time to: #{r.time.to_s.colorize(:green)}"
        @event.time_to = r
        return
      end
    end
  end

end
