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
    FileUtils.mv(PATH, PATH_BACKUP)
    # save to regular
    File.open(PATH, "w") do |f|
      f.puts(self.to_yaml)
    end
  end

  def self.add(e : Ocranizer::Event)
    c = new
    c.load
    c.add(e)
    c.save
  end

  def incoming
    return @array.select { |e| e.time_from }
  end
end
