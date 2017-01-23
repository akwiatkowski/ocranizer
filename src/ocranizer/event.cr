require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"

struct Ocranizer::Event
  YAML.mapping(
    title: String,
    place: String,
    desc: String,
    time_from: OcraTime,
    time_to: OcraTime
  )

  @time_from : OcraTime
  @time_to : OcraTime
  @title : String
  @place : String
  @desc : String

  def initialize
    @time_from = OcraTime.new_time_from
    @time_to = OcraTime.new_time_to
    @title = ""
    @place = ""
    @desc = ""
  end

  property :time_from, :time_to, :title, :desc, :place

  def show
    puts "#{title.colorize(:yellow)} (event)"
    puts "#{time_from.to_human.to_s.colorize(:green)} -> #{time_to.to_human.to_s.colorize(:green)}"
    puts "at: #{place.colorize(:yellow)}" if place.size > 0
    puts "details: #{desc.colorize(:yellow)}" if desc.size > 0
  end

  def self.add_from_command(string : String)
    sa = string.split(/,/)

    e = new
    e.time_from = OcraTime.parse_human(string: sa[0])
    e.time_to = OcraTime.parse_human(string: sa[1], base_time: e.time_from.time)
    e.title = sa[2]
    e.place = sa[3] if sa[3]?
    e.desc = sa[4] if sa[4]?

    c = Ocranizer::Collection.new
    c.load
    c.add(e)
    c.save

    return e
  end
end
