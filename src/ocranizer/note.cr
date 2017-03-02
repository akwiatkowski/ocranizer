require "yaml"
require "colorize"

require "./collection"
require "./decorators/sort"

class Ocranizer::Note
  include Ocranizer::Decorators::Sort

  YAML.mapping(
    id: String,
    created_at: Time,
    content: String
  )

  JSON.mapping(
    id: String,
    created_at: Time,
    content: String
  )

  def initialize
    @id = Time.now.to_local.to_s("%Y%m%d%H%M%S%L")
    @created_at = Time.now.to_local
    @content = String.new
  end

  property :id, :created_at, :content

  def valid?
    # check only name
    if content.size < 3
      return false
    else
      return true
    end
  end

  def <=>(other) : Int32
    return self.created_at <=> other.created_at
  end

  def after_load
  end

  def name
    content
  end

  def time_from
    created_at
  end

  def to_s_full
    st = String.build do |s|
      if false == valid?
        s << "INVALID".colorize(:red).to_s
        s << "\n"
      end

      s << "Content: "
      s << self.name.colorize(:yellow).to_s
      s << "\n"

      s << "Created_at: "
      s << self.created_at.to_s.colorize(:green).to_s
      s << "\n"

      s << "Id: "
      s << self.id.to_s
      s << "\n"
    end

    return st
  end

  def filter_hash?(params : Hash)
    # no filters
    return true if params.keys.size == 0

    # id - substring, ignore case
    if params["id"]?
      return false if self.id.downcase.index(params["id"].downcase).nil?
    end

    # name/content - substring, ignore case
    if params["name"]?
      return false if self.content.downcase.index(params["name"].downcase).nil?
    end
    if params["content"]?
      return false if self.content.downcase.index(params["name"].downcase).nil?
    end

    if params["time_from"]?
      t = OcraTime.parse_human(params["time_from"]).at_beginning
      return false if self.created_at < t
    end

    if params["time_to"]?
      t = OcraTime.parse_human(params["time_to"]).at_end
      return false if self.created_at > t
    end

    if params["day"]?
      tf = OcraTime.parse_human(params["day"]).at_beginning
      tt = OcraTime.parse_human(params["day"]).at_end

      if tf >= self.created_at && tt <= self.created_at
        # ok
      else
        return false
      end
    end

    return true
  end
end
