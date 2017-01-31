require "yaml"
require "json"
require "colorize"

require "./ocra_time"
require "./collection"
require "./entity"

class Ocranizer::Event
  include Ocranizer::Entity

  YAML.mapping(
    id: String,
    user: String,
    name: String,
    place: String,
    desc: String,
    category: String,
    tags: Array(String),
    time_from: OcraTime,
    time_to: OcraTime,
    url: (String | Nil)
  )

  JSON.mapping(
    id: String,
    user: String,
    name: String,
    place: String,
    desc: String,
    category: String,
    tags: Array(String),
    time_from: OcraTime,
    time_to: OcraTime,
    url: (String | Nil)
  )

  def initialize
    @id = Time.now.to_s("%Y%m%d%H%M%S%L")
    @user = String.new

    @time_from = OcraTime.new_time_from
    @time_to = OcraTime.new_time_to

    @name = String.new
    @place = String.new
    @desc = String.new

    @category = String.new
    @tags = Array(String).new
  end

  property :user, :time_from, :time_to, :name, :desc, :place, :category, :url

  def <=>(other) : Int32
    if self.time_from > other.time_from
      return 1
    elsif self.time_from < other.time_from
      return -1
    end
    return self.name <=> other.name
  end
end
