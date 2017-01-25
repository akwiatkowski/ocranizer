require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"

module Ocranizer::OrganizerEntity
  property :time_from, :time_to, :name, :desc, :place, :category

  def update_attributes(params : Hash(String, String))
    self.name = params["name"]
    self.place = params["place"]
    self.desc = params["desc"]
    self.time_from_string = params["time_from"] if params["time_from"]?
    self.time_to_string = params["time_to"] if params["time_to"]?
    self.category = params["category"]
    self.tags_string = params["tags"]
  end

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

  def save(force : Bool = false)
    if self.valid?
      if self.duplicate?
        # valid, but duplicate
        if force
          puts "Duplicate, but add forced"
          save!
        else
          puts "Duplicate, not saving"
        end
      else
        # valid and not duplicate
        save!
      end
    end
  end

  def save!
    Ocranizer::Collection.add(self)
  end

  def valid?
    if time_from.nil? || time_to.nil? || time_from.not_nil!.error? || time_to.not_nil!.error? || name.size < 3
      return false
    else
      return true
    end
  end

  def filter_hash?(params : Hash)
    # no filters
    return true if params.keys.size == 0

    # search for name
    if params["name"]?
      return false if self.name.index(params["name"]).nil?
    end

    if params["time_from"]?
      t = OcraTime.parse_human(params["time_from"]).at_beginning

      if self.as?(Ocranizer::Event)
        # Event must be within
        return false if self.time_from.not_nil!.time < t
      end

      if self.as?(Ocranizer::Todo)
        # if Todo has not `time_from` don't show
        # not important
        return false if self.time_from.nil?

        # if Todo has `time_from` it must be within
        return false if self.time_from.not_nil!.time < t
      end
    end

    if params["time_to"]?
      t = OcraTime.parse_human(params["time_to"]).at_end

      if self.as?(Ocranizer::Event)
        # Event must be within
        return false if self.time_to.not_nil!.time > t
      end

      if self.as?(Ocranizer::Todo)
        # if Todo has not `time_from` don't show
        # not important
        return false if self.time_to.nil?

        # if Todo has `time_from` it must be within
        return false if self.time_to.not_nil!.time > t
      end
    end

    if params["day"]?
      tf = OcraTime.parse_human(params["day"]).at_beginning
      tt = OcraTime.parse_human(params["day"]).at_end

      if self.as?(Ocranizer::Event)
        # Event must be within
        return false if self.time_from.not_nil!.time < tf && self.time_to.not_nil!.time > tt
      end

      if self.as?(Ocranizer::Todo)
        # if Todo has not `time_from` don't show
        # not important
        return false if self.time_from.nil?
        return false if self.time_to.nil?

        # if Todo has `time_from` it must be within
        return false if self.time_from.not_nil!.time < tf && self.time_to.not_nil!.time > tt
      end
    end

    return true
  end

  def duplicate?
    Ocranizer::Collection.duplicate?(self)
  end
end
