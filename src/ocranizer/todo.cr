require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"
require "./entity"

class Ocranizer::Todo
  include Ocranizer::Entity

  YAML.mapping(
    id: String,
    user: String,
    name: String,
    place: String,
    desc: String,
    category: String,
    tags: Array(String),
    time_from: (OcraTime | Nil),
    time_to: (OcraTime | Nil),
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
    time_from: (OcraTime | Nil),
    time_to: (OcraTime | Nil),
    url: (String | Nil)
  )

  def initialize
    @id = Time.now.to_s("%Y%m%d%H%M%S%L")
    @user = ""

    @time_from = nil
    @time_to = nil
    # @time_from = OcraTime.new_time_from
    # @time_to = OcraTime.new_time_to

    @name = String.new
    @place = String.new
    @desc = String.new

    @category = String.new
    @tags = Array(String).new
  end

  property :user, :time_from, :time_to, :name, :desc, :place, :category, :url

  def <=>(other) : Int32
    if self.time_from.nil?
      if other.time_from.nil?
        # compare name if not time_from
        return self.name <=> other.name
      else
        # other has `time_from` - always bigger prior
        return -1
      end
    else
      if other.time_from.nil?
        # compare name if not time_from
        return 1
      else
        # both of `time_to` is not null
      end
    end

    if self.time_to.not_nil! > other.time_to.not_nil!
      return 1
    elsif self.time_to.not_nil! < other.time_to.not_nil!
      return -1
    end
    return self.name <=> other.name
  end
end
