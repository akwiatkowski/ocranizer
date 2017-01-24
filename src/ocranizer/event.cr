require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"

struct Ocranizer::Event
  YAML.mapping(
    id: String,
    name: String,
    place: String,
    desc: String,
    category: String,
    tags: Array(String),
    time_from: OcraTime,
    time_to: OcraTime
  )

  def initialize
    @id = Time.now.to_s("%Y%m%d%H%M%S%L")
    @time_from = OcraTime.new_time_from
    @time_to = OcraTime.new_time_to
    @name = ""
    @place = ""
    @desc = ""
    @category = ""
    @tags = Array(String).new
  end

  property :time_from, :time_to, :name, :desc, :place

  def show
    puts "#{name.colorize(:yellow)} (event)"
    puts "#{time_from.to_human.to_s.colorize(:green)} -> #{time_to.to_human.to_s.colorize(:green)}"
    puts "at: #{place.colorize(:yellow)}" if place.size > 0
    puts "details: #{desc.colorize(:yellow)}" if desc.size > 0
  end

  def show_inline
    st = String.build do |s|
      s << name[0..20].colorize(:yellow).to_s.ljust(28)
      s << time_from.to_human.colorize(:green).to_s.ljust(32)
      s << time_to.to_human.colorize(:green).to_s.ljust(32)
    end

    puts st
  end

  def time_from_string=(s : String)
    time_from = OcraTime.parse_human(string: s)
  end

  def time_to_string=(s : String)
    time_to = OcraTime.parse_human(string: s, base_time: time_from.time)
  end

  def tags_string=(s : String)
    s.split(/,/).each do |t|
      @tags << t.strip
    end
  end

  def save
  end

  def self.add_from_string(string : String)
    sa = string.split(/,/)

    e = new
    e.time_from = OcraTime.parse_human(string: sa[0])
    e.time_to = OcraTime.parse_human(string: sa[1], base_time: e.time_from.time)
    e.name = sa[2]
    e.place = sa[3] if sa[3]?
    e.desc = sa[4] if sa[4]?

    Ocranizer::Collection.add(e)

    return e
  end
end
