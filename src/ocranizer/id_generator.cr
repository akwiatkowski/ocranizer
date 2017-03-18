class Ocranizer::IdGenerator
  FIX_ID          = false
  SEPARATOR       = "_"
  REQUIRED_LENGTH =  3
  CROP_SIZE       = 22

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

  def self.long_enough?(id : String)
    return id.size > REQUIRED_LENGTH
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
    splits = splits.map { |s| s.downcase.gsub(/\W/, "") }
    splits = splits.select { |s| s.size < 20 && s.size > 2 }

    string = ""
    if entity.responds_to?(:min_time) && entity.min_time
      string += entity.min_time.not_nil!.to_s_day_safe
      string += "_"
    end
    string += splits.join(SEPARATOR)
    string = string[0..CROP_SIZE]

    while false == uniq?(string) || false == long_enough?(string)
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
