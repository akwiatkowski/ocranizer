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
    url: (String | Nil),
    priority: (Int32 | Nil),
    completed: (Bool | Nil),
    completed_at: (Time | Nil),
    repeat_entity: (Bool | Nil),
    repeat_initial: (Ocranizer::OcraTime | Nil),
    repeat_until: (Ocranizer::OcraTime | Nil),
    repeat_interval_string: (String | Nil),
    repeat_count: (Int32 | Nil)
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
    url: (String | Nil),
    priority: (Int32 | Nil),
    completed: (Bool | Nil),
    completed_at: (Time | Nil),
    repeat_entity: (Bool | Nil),
    repeat_initial: (Ocranizer::OcraTime | Nil),
    repeat_until: (Ocranizer::OcraTime | Nil),
    repeat_interval_string: (String | Nil),
    repeat_count: (Int32 | Nil)
  )

  def initialize
    @id = Time.now.to_local.to_s("%Y%m%d%H%M%S%L")
    @user = String.new

    @time_from = OcraTime.new_time_from
    @time_to = OcraTime.new_time_to

    @name = String.new
    @place = String.new
    @desc = String.new

    @category = String.new
    @tags = Array(String).new
  end

  property :user, :time_from, :time_to, :name, :desc, :place, :category, :url, :priority
  # repeatition
  property :repeat_entity          # Bool | Nil - true if object qualify as repeatited
  property :repeat_initial         # OcraTime | Nil - copied `time_from`
  property :repeat_until           # OcraTime | Nil - when end repeatition
  property :repeat_interval_string # String | Nil - how often repeat
  property :repeat_count           # Int32 | Nil - how many times repeat


  def <=>(other) : Int32
    if self.time_from > other.time_from
      return 1
    elsif self.time_from < other.time_from
      return -1
    end
    return self.name <=> other.name
  end

  def update_attributes(params : Hash(String, String))
    super(params)
    if params["time_to"]?.nil? && self.time_from.fullday?
      self.time_to.type = self.time_from.type

      self.time_to.time = self.time_from.time
      self.time_to.time = self.time_to.at_end_of_day
    end
  end
end
