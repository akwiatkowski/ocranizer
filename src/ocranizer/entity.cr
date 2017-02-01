require "yaml"
require "colorize"

require "./ocra_time"
require "./collection"

module Ocranizer::Entity
  DEFAULT_USER = ""

  PRIORITY_IMPORTANT = 100
  PRIORITY_URGENT    =  10
  PRIORITY_REGULAR   =   0
  PRIORITY_LOW       = -10

  PRIORITY_IMPORTANT_STRING = "important"
  PRIORITY_URGENT_STRING    = "urgent"
  PRIORITY_REGULAR_STRING   = nil
  PRIORITY_LOW_STRING       = "low"

  property :user, :time_from, :time_to, :name, :desc, :place, :category, :url, :priority

  def update_attributes(params : Hash(String, String))
    # NOTE: id cannot be changed
    self.user = params["user"] if params["user"]?
    self.name = params["name"] if params["name"]?
    self.place = params["place"] if params["place"]?
    self.desc = params["desc"] if params["desc"]?
    self.time_from_string = params["time_from"] if params["time_from"]?
    self.time_to_string = params["time_to"] if params["time_to"]?
    self.category = params["category"] if params["category"]?
    self.tags_string = params["tags"] if params["tags"]?
    self.url = params["url"] if params["url"]?
    self.priority_string = params["priority"] if params["priority"]?
  end

  def to_s_full
    st = String.build do |s|
      if false == valid?
        s << "INVALID".colorize(:red).to_s
        s << "\n"
      end

      s << "Name: "
      s << self.name.colorize(:yellow).to_s
      s << "\n"

      s << "Time: "
      s << self.time_from.not_nil!.to_human.to_s.colorize(:green).to_s if self.time_from
      s << " -> "
      s << self.time_to.not_nil!.to_human.to_s.colorize(:green).to_s if self.time_to
      s << "\n"

      s << "Place: "
      if self.place.size > 0
        s << self.place.colorize(:yellow).to_s
      end
      s << "\n"

      s << "Desc: "
      if self.desc.size > 0
        s << self.desc.colorize(:yellow).to_s
      end
      s << "\n"

      s << "URL: "
      if self.url.to_s.size > 0
        s << self.url.colorize(:blue).to_s
      end
      s << "\n"

      s << "Category: "
      if self.category.size > 0
        s << self.category.colorize(:magenta).to_s
      end
      s << "\n"

      s << "Tags: "
      if self.tags.size > 0
        s << self.tags.join(", ").colorize(:cyan).to_s
      end
      s << "\n"

      s << "Id: "
      s << self.id.to_s
      s << "\n"

      s << "User: "
      s << self.user.to_s
      s << "\n"
    end

    return st
  end

  def to_s_inline
    st = String.build do |s|
      s << ("[" + self.id + "]").colorize(:dark_gray).to_s.ljust(28)

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

  def priority_string=(s : String)
    if s == PRIORITY_IMPORTANT_STRING
      self.priority = PRIORITY_IMPORTANT
      return
    end

    if s == PRIORITY_URGENT_STRING
      self.priority = PRIORITY_URGENT
      return
    end

    if s == PRIORITY_LOW_STRING
      self.priority = PRIORITY_LOW
      return
    end
  end

  def valid?
    if time_from.nil? ||
       time_to.nil? ||
       time_from.not_nil!.error? ||
       time_to.not_nil!.error? ||
       name.size < 3 ||
       time_from.not_nil!.time > time_to.not_nil!.time
      return false
    else
      return true
    end
  end

  def important?
    return false if self.priority.nil?
    return self.priority.not_nil! >= PRIORITY_IMPORTANT
  end

  def urgent?
    return false if self.priority.nil?
    return self.priority.not_nil! == PRIORITY_IMPORTANT
  end

  def low_priority?
    return false if self.priority.nil?
    return self.priority.not_nil! < PRIORITY_REGULAR
  end

  def filter_hash?(params : Hash)
    # no filters
    return true if params.keys.size == 0

    # user - "all" return from all user, "rest" return only not blank users,
    # "<user>" return only <user>, ""/nil return self because blank is the "I" user

    if nil == params["user"]? || DEFAULT_USER == params["user"]?
      # show only "I"
      return false if self.user != DEFAULT_USER
    elsif "all" == params["user"]
      # show all
      # not return false, move to rest filters
    elsif "rest" == params["user"]
      return false if self.user == DEFAULT_USER
    else
      # show only <user>
      return false if self.user != params["user"]
    end

    # id - substring, ignore case
    if params["id"]?
      return false if self.id.downcase.index(params["id"].downcase).nil?
    end

    # name - substring, ignore case
    if params["name"]?
      return false if self.name.downcase.index(params["name"].downcase).nil?
    end

    # place - substring, ignore case
    if params["place"]?
      return false if self.place.downcase.index(params["place"].downcase).nil?
    end

    # desc - substring, ignore case
    if params["desc"]?
      return false if self.desc.downcase.index(params["desc"].downcase).nil?
    end

    # desc - substring, ignore case
    if params["url"]?
      return false if self.url.to_s.downcase.index(params["url"].downcase).nil?
    end

    # tag - exact, case
    if params["tags"]?
      return false if self.tags.index(params["tags"]).nil?
    end

    # category - exact, case
    if params["category"]?
      return false if self.category.strip != params["category"].strip
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
        of = self.time_from.not_nil!.at_beginning
        ot = self.time_to.not_nil!.at_end

        if tf >= of && tt <= ot
          # ok
        else
          return false
        end
      end

      if self.as?(Ocranizer::Todo)
        # if Todo has not `time_from` don't show
        # not important
        return false if self.time_from.nil?
        return false if self.time_to.nil?

        # TODO add if one of them is Nil

        # if Todo has `time_from` it must be within
        of = self.time_from.not_nil!.at_beginning
        ot = self.time_to.not_nil!.at_end

        if tf >= of && tt <= ot
          # ok
        else
          return false
        end
      end
    end

    return true
  end

  def >(other)
    (self <=> other) == 1
  end

  def <(other)
    (self <=> other) == -1
  end

  def >=(other)
    (self <=> other) == 1 || (self <=> other) == 0
  end

  def <=(other)
    (self <=> other) == -1 || (self <=> other) == 0
  end

  def is_within?(day : Time) : Bool
    # TODO: add Todo with one time
    return false if self.time_to.nil? || self.time_from.nil?

    t = day.at_beginning_of_day
    tf = self.time_from.not_nil!.time.at_beginning_of_day
    tt = self.time_to.not_nil!.time.at_end_of_day

    # daytime is within Entity range
    return true if t >= tf && t <= tt

    if t.at_beginning_of_day == tf.at_beginning_of_day ||
       t.at_beginning_of_day == tt.at_beginning_of_day
      return true
    end

    return false
  end
end
