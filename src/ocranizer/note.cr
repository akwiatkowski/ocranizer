require "yaml"
require "colorize"

require "./collection"
require "./decorators/sort"

class Ocranizer::Note
  include Ocranizer::Decorators::Sort

  YAML.mapping(
    id: String,
    created_at: Time,
    content: String
  )

  JSON.mapping(
  id: String,
  created_at: Time,
  content: String
  )

  def initialize
    @id = Time.now.to_local.to_s("%Y%m%d%H%M%S%L")
    @created_at = Time.now.to_local
    @content = String.new
  end

  property :id, :created_at, :content

  def valid?
    # check only name
    if content.size < 3
      return false
    else
      return true
    end
  end

  def <=>(other) : Int32
    return self.created_at <=> other.created_at
  end

  def after_load
  end

  def name
    content
  end

  def time_from
    created_at
  end

  def to_s_full
    st = String.build do |s|
      if false == valid?
        s << "INVALID".colorize(:red).to_s
        s << "\n"
      end

      s << "Content: "
      s << self.name.colorize(:yellow).to_s
      s << "\n"

      s << "Created_at: "
      s << self.created_at.to_s.colorize(:green).to_s
      s << "\n"

      s << "Id: "
      s << self.id.to_s
      s << "\n"
    end

    return st
  end
end
