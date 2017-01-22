require "yaml"

require "./event"

class Ocranizer::Collection
  PATH = "/home/#{`whoami`.to_s.strip}/ocranizer.yml"

  YAML.mapping(
    array: Array(Ocranizer::Event)
  )

  getter :array

  def initialize
    @array = Array(Ocranizer::Event).new
  end

  def self.touch
    `touch #{PATH}`
  end

  def add(e : Ocranizer::Event)
    @array << e
  end

  def load
    if File.exists?(PATH)
      o = Ocranizer::Collection.from_yaml(File.read(PATH))
      @array = o.array
    end
  end

  def save
    File.open(PATH, "w") do |f|
      f.puts(self.to_yaml)
    end
  end

  def last
    if @array.size > 0
      @array.last
    else
      return nil
    end
  end
end
