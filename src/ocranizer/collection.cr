require "yaml"
require "file_utils"

require "./event"
require "./todo"
require "./note"
require "./id_generator"

class Ocranizer::Collection
  # path
  DEFAULT_PATH         = "/home/#{`whoami`.to_s.strip}/.ocranizer.yml"
  DEFAULT_BACKUP_SUFIX = ".bak"

  @@path = DEFAULT_PATH.as(String)
  @@path_backup = (DEFAULT_PATH + DEFAULT_BACKUP_SUFIX).as(String)

  def self.path=(p : String)
    @@path = p
    @@path_backup = p + DEFAULT_BACKUP_SUFIX
  end

  def self.path
    @@path
  end

  def self.path_backup
    @@path_backup
  end

  # end of path

  YAML.mapping(
    events: Array(Ocranizer::Event),
    todos: Array(Ocranizer::Todo),
    notes: (Array(Ocranizer::Note) | Nil)
  )

  getter :events, :todos

  def initialize
    @events = Array(Ocranizer::Event).new
    @todos = Array(Ocranizer::Todo).new
    @notes = Array(Ocranizer::Note).new
  end

  def add!(e : Ocranizer::Event)
    ne = make_id_uniq(e)
    @events << ne
    @events.sort!
    return ne
  end

  def add!(e : Ocranizer::Todo)
    ne = make_id_uniq(e)
    @todos << ne
    @todos.sort!
    return ne
  end

  def add!(e : Ocranizer::Note)
    ne = make_id_uniq(e)
    @notes.not_nil! << ne
    @notes.not_nil!.sort!
    return ne
  end

  def add(entity : (Ocranizer::Event | Ocranizer::Todo | Ocranizer::Note), force : Bool = false)
    if entity.valid?
      if duplicate?(entity)
        # valid, but duplicate
        if force
          # puts "Duplicate, but add forced"
          return add!(entity)
        else
          # puts "Duplicate, not saving"
          return nil
        end
      else
        # valid and not duplicate
        return add!(entity)
      end
    end
    return nil
  end

  def remove(e : Ocranizer::Event)
    @events = @events.select { |a| a.id != e.id }
  end

  def remove(e : Ocranizer::Todo)
    @todos = @todos.select { |a| a.id != e.id }
  end

  def remove(e : Ocranizer::Note)
    @notes = @notes.select { |a| a.id != e.id }
  end

  def load
    if File.exists?(self.class.path)
      # load regular
      o = Ocranizer::Collection.from_yaml(File.read(self.class.path))
      @events = o.events
      @todos = o.todos
      # safe migration from version without notes
      if o.notes
        @notes = o.notes.not_nil!
        @notes.not_nil!.sort!
      end

      @events.sort!
      @todos.sort!
    elsif File.exists?(self.class.path_backup)
      # try loading backup
      o = Ocranizer::Collection.from_yaml(File.read(self.class.path_backup))
      @events = o.events
      @todos = o.todos
      # safe migration from version without notes
      if o.notes
        @notes = o.notes.not_nil!
        @notes.not_nil!.sort!
      end

      @events.sort!
      @todos.sort!
    end

    # after load for repeated
    @events.each do |e|
      e.after_load
    end
    @todos.each do |e|
      e.after_load
    end
    @notes.not_nil!.each do |e|
      e.after_load
    end

    # to unique id generator
    Ocranizer::IdGenerator.add(@events.not_nil!)
    Ocranizer::IdGenerator.add(@todos.not_nil!)
    Ocranizer::IdGenerator.add(@notes.not_nil!)

    save
  end

  def save
    # do a backup
    FileUtils.mv(self.class.path, self.class.path_backup) if File.exists?(self.class.path)

    # save to regular
    File.open(self.class.path, "w") do |f|
      f.puts(self.to_yaml)
    end
  end

  def is_id_uniq?(id : String)
    return false == (@events.map(&.id) + @todos.map(&.id)).includes?(id)
  end

  # Add random number as long as `id` will be unique
  def make_id_uniq(e : (Ocranizer::Entity | Ocranizer::Note))
    while false == is_id_uniq?(e.id)
      e.id += rand(10).to_s
    end
    return e
  end

  def events(params : Hash)
    events.sort.select { |e| e.filter_hash?(params) }
  end

  def todos(params : Hash)
    todos.sort.select { |e| e.filter_hash?(params) }
  end

  def notes(params : Hash)
    notes.not_nil!.sort.select { |e| e.filter_hash?(params) }
  end

  def incoming_events(max : Int32 = 20)
    tf = Ocranizer::OcraTime.now.at_beginning_of_day
    return @events.select { |e| e.time_from.at_beginning_of_day >= tf }.sort { |a, b| a.time_from.time <=> b.time_from.time }[0...max]
  end

  def incoming_todos(max : Int32 = 20)
    tf = Ocranizer::OcraTime.now.at_end_of_day
    todos = @todos.select { |e| e.time_to }.select { |e| e.time_to.not_nil!.time.not_nil! <= tf }.sort { |a, b| a.time_to.not_nil!.time <=> b.time_to.not_nil!.time }
    return todos[0...max]
  end

  def duplicate?(e : (Ocranizer::Event | Ocranizer::Todo | Ocranizer::Note))
    return (self.events + self.todos + self.notes.not_nil!).select { |f| e.name == f.name && e.time_from == f.time_from }.size > 0
  end

  def get_event(id : String)
    return self.events.select { |e| e.id == id }[0]?
  end

  def get_todo(id : String)
    return self.todos.select { |e| e.id == id }[0]?
  end
end
