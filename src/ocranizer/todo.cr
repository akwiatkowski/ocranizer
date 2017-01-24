require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"

struct Ocranizer::Todo
  YAML.mapping(
    id: String,
    name: String,
    place: String,
    desc: String,
    category: String,
    tags: Array(String),
    time_from: (OcraTime | Nil),
    time_to: (OcraTime | Nil)
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

  def to_s_full
    st = String.build do |s|
      if false == valid?
        s << "INVALID".colorize(:red).to_s
        s << "\n"
      end

      s << self.name.colorize(:yellow).to_s
      s << "\n"

      s << self.time_from.not_nil!.to_human.to_s.colorize(:green).to_s if self.time_from
      s << " -> "
      s << self.time_to.not_nil!.to_human.to_s.colorize(:green).to_s if self.time_to
      s << "\n"

      if self.place.size > 0
        s << "at: "
        s << self.place.colorize(:yellow).to_s
        s << "\n"
      end

      if self.desc.size > 0
        s << "details: "
        s << self.desc.colorize(:yellow).to_s
        s << "\n"
      end

      if self.category.size > 0
        s << "category: "
        s << self.category.colorize(:magenta).to_s
        s << "\n"
      end

      if self.tags.size > 0
        s << "tags: "
        s << self.tags.join(", ").colorize(:cyan).to_s
        s << "\n"
      end

      s << "Id: "
      s << self.id.to_s
      s << "\n"
    end

    return st
  end

  def self.inline_head
    # TODO
  end

  def to_s_inline
    st = String.build do |s|
      s << self.name[0..28].colorize(:yellow).to_s.rjust(36)
      s << " : "

      if self.time_from
        s << self.time_from.not_nil!.to_human.colorize(:green).to_s.ljust(25)
      else
        s << "".ljust(25)
      end

      s << " - "

      if self.time_to
        s << self.time_to.not_nil!.to_human.colorize(:green).to_s.ljust(25)
      else
        s << "".ljust(25)
      end

      s << " "
      s << ("[" + self.id + "]").colorize(:dark_gray).to_s.ljust(28)
      s << " "
      s << self.category.colorize(:cyan)

      if self.tags.size > 0
        s << ", "
        s << self.tags.join(", ")[0..20].colorize(:magenta)
      end

    end

    return st
  end

  def time_from_string=(s : String)
    self.time_from = OcraTime.parse_human(string: s)
  end

  def time_to_string=(s : String)
    t = nil
    t = self.time_from.not_nil!.time if self.time_from
    self.time_to = OcraTime.parse_human(string: s, base_time: t)
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
    if name.size < 3
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
