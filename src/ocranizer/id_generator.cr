class Ocranizer::IdGenerator
  FIX_ID = false
  SEPARATOR = "+"

  @@array = Array(String).new

  def self.add(id : String)
    raise "ID duplicated" if false == uniq?(id)
    @@array << id
  end

  def self.add(array : Array)
    array.each do |obj|
      add(obj.id)
      change_id(obj) if FIX_ID
    end
  end

  def self.uniq?(id : String)
    false == @@array.includes?(id)
  end

  def self.change_id(entity)
    old_id = entity.id

    @@array = @@array - [entity.id]
    entity.id = generate(entity)
    add(entity.id)

    puts "change ID from #{old_id} to #{entity.id}"
  end

  def self.generate(entity, repeated_number : (Int | Nil) = nil)
    splits = entity.name.split(" ")
    splits = splits.map{|s| s.downcase.gsub(/\W/, "") }
    splits = splits.select{|s| s.size < 20 && s.size > 2 }

    string = splits.join(SEPARATOR)
    string = string[0..15]

    while false == uniq?(string)
      string += random_char.downcase
    end

    if repeated_number
      string += SEPARATOR + repeated_number.to_s
    end

    return string
  end

  def self.random_char
    return (65 + rand(25)).chr
  end
end
