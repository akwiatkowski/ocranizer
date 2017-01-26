require "yaml"
require "file_utils"

require "./event"
require "./todo"

class Ocranizer::Collection
  PATH        = "/home/#{`whoami`.to_s.strip}/.ocranizer.yml"
  PATH_BACKUP = PATH + ".bak"

  YAML.mapping(
    events: Array(Ocranizer::Event),
    todos: Array(Ocranizer::Todo)
  )

  getter :events, :todos

  def initialize
    @events = Array(Ocranizer::Event).new
    @todos = Array(Ocranizer::Todo).new
  end

  def add(e : Ocranizer::Event)
    ne = make_id_uniq(e)
    @events << ne
    return ne
  end

  def add(e : Ocranizer::Todo)
    ne = make_id_uniq(e)
    @todos << ne
    return ne
  end

  def remove(e : Ocranizer::Event)
    @events = @events.select { |a| a.id != e.id }
  end

  def remove(e : Ocranizer::Todo)
    @todos = @todos.select { |a| a.id != e.id }
  end

  def load
    if File.exists?(PATH)
      # load regular
      o = Ocranizer::Collection.from_yaml(File.read(PATH))
      @events = o.events
      @todos = o.todos
    elsif File.exists?(PATH_BACKUP)
      # try loading backup
      o = Ocranizer::Collection.from_yaml(File.read(PATH_BACKUP))
      @events = o.events
      @todos = o.todos
    end
  end

  def save
    # do a backup
    FileUtils.mv(PATH, PATH_BACKUP) if File.exists?(PATH)

    # save to regular
    File.open(PATH, "w") do |f|
      f.puts(self.to_yaml)
    end
  end

  def is_id_uniq?(id : String)
    return false == (@events.map(&.id) + @todos.map(&.id)).includes?(id)
  end

  # Add random number as long as `id` will be unique
  def make_id_uniq(e : Ocranizer::Entity)
    while false == is_id_uniq?(e.id)
      e.id += rand(10).to_s
    end
    return e
  end

  def events(params : Hash)
    events.select { |e| e.filter_hash?(params) }
  end

  def todos(params : Hash)
    todos.select { |e| e.filter_hash?(params) }
  end

  def incoming_events(max : Int32 = 20)
    tf = Time.now.at_beginning_of_day
    return @events.select { |e| e.time_from.at_beginning_of_day >= tf }.sort { |a, b| a.time_from.time <=> b.time_from.time }[0...max]
  end

  def incoming_todos(max : Int32 = 20)
    tf = Time.now.at_end_of_day
    todos = @todos.select { |e| e.time_to }.select { |e| e.time_to.not_nil!.time.not_nil! <= tf }.sort { |a, b| a.time_to.not_nil!.time <=> b.time_to.not_nil!.time }
    return todos[0...max]
  end

  def self.add(e : (Ocranizer::Event | Ocranizer::Todo))
    c = new
    c.load
    c.add(e)
    c.save
  end

  def self.update(e : (Ocranizer::Event | Ocranizer::Todo))
    c = new
    c.load
    c.remove(e)
    c.add(e)
    c.save
  end

  def self.duplicate?(e : Ocranizer::Event)
    c = new
    c.load

    return c.events.select { |f| e.name == f.name && e.time_from == f.time_from }.size > 0
  end

  def self.duplicate?(e : Ocranizer::Todo)
    c = new
    c.load

    return c.events.select { |f| e.name == f.name && e.time_from == f.time_from }.size > 0
  end

  def self.incoming_events(max : Int32 = 20)
    c = new
    c.load
    return c.incoming_events(max: max)
  end

  def self.incoming_todos(max : Int32 = 20)
    c = new
    c.load
    return c.incoming_todos(max: max)
  end

  def self.get_event(id : String)
    c = new
    c.load
    return c.events.select { |e| e.id == id }[0]?
  end

  def self.get_todo(id : String)
    c = new
    c.load
    return c.todos.select { |e| e.id == id }[0]?
  end
end
