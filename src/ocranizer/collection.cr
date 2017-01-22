require "yaml"

class Ocranizer::Collection
  PATH = "/home/#{`whoami`.to_s.strip}/ocranizer.yml"

  YAML.mapping(
    array: Array(Ocranizer::Event)
  )

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
    o = Ocranizer::Collection.from_yaml(File.read(PATH))
    @array = o.array
  end

  def save
    File.open(PATH, "w") do |f|
      f.puts(self.to_yaml)
    end
  end
end
