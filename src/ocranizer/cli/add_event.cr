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
    get_title
    get_place
    get_desc

    confirm
    save

    show
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
      s = "next hour" if s.to_s.strip == ""
      r = OcraTime.parse_human(string: s.to_s, base_time: @event.time_from.time)

      if r.not_error?
        puts "Time to: #{r.time.to_s.colorize(:green)}"
        @event.time_to = r
        return
      end
    end
  end

  def get_title
    loop do
      puts "Title?"
      s = gets

      if s.to_s.size > 2
        @event.title = s.to_s
        puts "Title: #{@event.title.colorize(:yellow)}"
        return
      end
    end
  end

  def get_place
    puts "Place?"
    s = gets
    @event.place = s.to_s
    puts "Place: #{@event.place.colorize(:yellow)}"
  end

  def get_desc
    puts "Desc?"
    s = gets
    @event.desc = s.to_s
    puts "Desc: #{@event.place.colorize(:yellow)}"
  end

  def confirm
    gets
  end

  def save
    c = Ocranizer::Collection.new
    c.load
    c.add(@event)
    c.save
  end

  def show
    @event.show
  end

end
