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

  def to_s_full
    st = String.build do |s|
      if false == valid?
        s << "INVALID".colorize(:red).to_s
        s << "\n"
      end

      s << name.colorize(:yellow).to_s
      s << "\n"

      s << time_from.to_human.to_s.colorize(:green).to_s
      s << " -> "
      s << time_to.to_human.to_s.colorize(:green).to_s
      s << "\n"

      if place.size > 0
        s << "at: "
        s << place.colorize(:yellow).to_s
        s << "\n"
      end

      if desc.size > 0
        s << "details: "
        s << desc.colorize(:yellow).to_s
        s << "\n"
      end

      if category.size > 0
        s << "category: "
        s << category.colorize(:magenta).to_s
        s << "\n"
      end

      if tags.size > 0
        s << "tags: "
        s << tags.join(", ").colorize(:cyan).to_s
        s << "\n"
      end

      s << "Id: "
      s << id.to_s
      s << "\n"
    end

    return st
  end

  def to_s_inline
    st = String.build do |s|
      s << name[0..28].colorize(:yellow).to_s.rjust(36)
      s << " : "
      s << time_from.to_human.colorize(:green).to_s.ljust(25)
      s << " - "
      s << time_to.to_human.colorize(:green).to_s.ljust(32)
    end

    return st
  end

  def time_from_string=(s : String)
    self.time_from = OcraTime.parse_human(string: s)
  end

  def time_to_string=(s : String)
    self.time_to = OcraTime.parse_human(string: s, base_time: time_from.time)
  end

  def tags_string=(s : String)
    s.split(/,/).each do |t|
      v = t.strip
      @tags << v if v != ""
    end
  end

  def save
    Ocranizer::Collection.add(self)
  end

  def valid?
    if time_from.error? || time_to.error? || name.size < 3
      return false
    else
      return true
    end
  end

  def duplicate?
    Ocranizer::Collection.duplicate?(self)
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
