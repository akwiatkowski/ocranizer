require "yaml"
require "colorize"

require "./ocra_time"

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
    puts "Event: #{title.colorize(:yellow)}"
    puts "from: #{time_from.time.to_s.colorize(:green)}"
    puts "to: #{time_to.time.to_s.colorize(:green)}"
    puts "place: #{place.colorize(:yellow)}"
    puts "desc: #{place.colorize(:yellow)}"
  end
end
