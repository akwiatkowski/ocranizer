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
  # repeatition
  property :repeat_entity   # Bool | Nil - true if object qualify as repeatited
  property :repeat_initial  # OcraTime | Nil - copied `time_from`
  property :repeat_until    # OcraTime | Nil - when end repeatition
  property :repeat_interval # Time::Span | Nil - how often repeat
  property :repeat_count    # Int32 | Nil - how many times repeat


  def after_load
    repeatition_iterate_until_now
  end

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
    # repeatitions
    # macros
    case params["repeat"]?
    when "monthly"
      params["repeat_interval"] = "1 month"
    end
    # direct params
    self.repeat_until_string = params["repeat_until"] if params["repeat_until"]?
    self.repeat_interval_string = params["repeat_interval"] if params["repeat_interval"]?
    self.repeat_count = params["repeat_count"].to_i if params["repeat_count"]?
    repeatition_update_attributes
  end

  def is_repeated?
    if (self.time_from || self.time_to) && self.repeat_interval_string
      return true
    else
      return false
    end
  end

  private def repeatition_update_attributes
    # both times are required for repeatition
    if self.time_from.nil? && self.time_to.nil?
      self.repeat_entity = false
    end

    # the only required attr to start repeated Entity is `repeat_interval_string`
    if self.repeat_interval_string
      self.repeat_entity = true

      # update only if not set
      if self.time_from
        self.repeat_initial ||= self.time_from.not_nil!
      elsif self.time_to
        self.repeat_initial ||= self.time_to.not_nil!
      else
        # should not occur
      end
    end
  end

  def repeatition_iterate_until_now
    # check if its repeatition Entity
    return false unless self.is_repeated?

    while self.max_time <= Ocranizer::OcraTime.now
      repeatition_iterate_time_ranges
    end
  end

  def repeatition_iterate_time_ranges
    # check if its repeatition Entity
    return false unless self.is_repeated?

    # `repeat_count` nil means repeat infinite
    # `repeat_count` is number, update times and decrement
    if self.repeat_count.nil? || self.repeat_count.not_nil! > 0
      span = Ocranizer::OcraTimeSpan.new(string: repeat_interval_string.not_nil!)

      if self.time_from
        self.time_from.not_nil!.time = span + self.time_from.not_nil!.time
      end
      if self.time_to
        self.time_to.not_nil!.time = span + self.time_to.not_nil!.time
      end
      if self.repeat_count
        # decrement limited repeatitions
        self.repeat_count = self.repeat_count.not_nil! - 1
      end

      return true
    end

    return false
  end

  # return next Entity or nil for
  def next_entity : (Entity | Nil)
    return nil if false == self.is_repeated?

    # clone without id
    new_entity = self.clone

    # decrement repeat count
    result = new_entity.repeatition_iterate_time_ranges

    # create fake ID
    new_entity.id = new_entity.max_time.to_local.to_s("%Y%m%d%H%M%S%L") + "_" + rand(10_000).to_s

    if result
      # could be created (ex: count > 0)
      return new_entity
    else
      return nil
    end
  end

  def next_entities_until(time : Time)
    a = Array(Entity).new
    e = self
    in_loop = true

    while in_loop
      ne = e.next_entity
      if ne && ne.not_nil!.max_time <= time
        a << ne
        e = ne
      else
        in_loop = false
      end
    end

    return a
  end

  def max_time : Time
    [self.time_from, self.time_to].select { |t| t }.map { |t| t.not_nil!.time }.max
  end

  def clone
    new_entity = self.class.new

    new_entity.category = self.category
    new_entity.desc = self.desc
    new_entity.name = self.name
    new_entity.place = self.place
    new_entity.priority = self.priority
    new_entity.repeat_count = self.repeat_count
    new_entity.repeat_entity = self.repeat_entity
    new_entity.repeat_initial = self.repeat_initial
    new_entity.repeat_interval_string = self.repeat_interval_string
    new_entity.repeat_until = self.repeat_until
    new_entity.tags = self.tags
    new_entity.time_from = self.time_from
    new_entity.time_to = self.time_to
    new_entity.url = self.url
    new_entity.user = self.user

    return new_entity
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

      if self.important?
        s << "Priority: "
        s << "IMPORTANT".colorize(:red)
        s << "\n"
      elsif self.urgent?
        s << "Priority: "
        s << "Urgent".colorize(:yellow)
        s << "\n"
      elsif self.low_priority?
        s << "Priority: "
        s << "low".colorize(:blue)
        s << "\n"
      end
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

    # special case
    # if `time_from` is `TYPE_FULLDAY` and `time_to` is `TYPE_RELATIVE`
    # change `time_to` to `TYPE_FULLDAY`
    if self.time_from &&
       self.time_to &&
       self.time_from.not_nil!.fullday?
      self.time_to.not_nil!.relative?

      self.time_to.not_nil!.type = Ocranizer::OcraTime::TYPE_FULLDAY
    end
  end

  def repeat_until_string=(s : String)
    self.repeat_until = OcraTime.parse_human(string: s)
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
    t = day.at_beginning_of_day

    # when `time_from` is nil and `time_to` is set as a deadline
    if self.time_to && self.time_from.nil?
      tt = self.time_to.not_nil!.time.at_end_of_day
      return true if tt.at_beginning_of_day == t.at_beginning_of_day
    end

    return false if self.time_to.nil? || self.time_from.nil?

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
