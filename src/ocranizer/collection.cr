require "yaml"
require "file_utils"

require "./event"

class Ocranizer::Collection
  PATH        = "/home/#{`whoami`.to_s.strip}/.ocranizer.yml"
  PATH_BACKUP = PATH + ".bak"

  YAML.mapping(
    array: Array(Ocranizer::Event)
  )

  getter :array

  def initialize
    @array = Array(Ocranizer::Event).new
  end

  def add(e : Ocranizer::Event)
    @array << e
  end

  def load
    if File.exists?(PATH)
      # load regular
      o = Ocranizer::Collection.from_yaml(File.read(PATH))
      @array = o.array
    elsif File.exists?(PATH_BACKUP)
      # try loading backup
      o = Ocranizer::Collection.from_yaml(File.read(PATH_BACKUP))
      @array = o.array
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

  def incoming(max : Int32 = 20)
    tf = Time.now.at_beginning_of_day
    return @array.select{|e| e.time_from.at_beginning_of_day >= tf}.sort{|a,b| a.time_from.time <=> b.time_from.time }[0...max]
  end

  def self.add(e : Ocranizer::Event)
    c = new
    c.load
    c.add(e)
    c.save
  end

  def self.duplicate?(e : Ocranizer::Event)
    c = new
    c.load

    return c.array.select{|f| e.name == f.name && e.time_from == f.time_from }.size > 0
  end

  def self.incoming(max : Int32 = 20)
    c = new
    c.load
    return c.incoming(max: max)
  end

  def self.get(id : String)
    c = new
    c.load
    return c.array.select{|e| e.id == id}.first
  end
end
