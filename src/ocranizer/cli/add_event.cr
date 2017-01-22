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
end
