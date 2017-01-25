require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"
require "./organizer_entity"

class Ocranizer::Event
  include Ocranizer::OrganizerEntity
  
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

  property :time_from, :time_to, :name, :desc, :place, :category

end
