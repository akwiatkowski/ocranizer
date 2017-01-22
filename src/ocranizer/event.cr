require "yaml"

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
end
