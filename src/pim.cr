require "option_parser"

require "./ocranizer/event"
require "./ocranizer/collection"

b_incoming = false
b_add = false
b_force = false
b_show = false

s_id = String.new
s_name = String.new
s_time_from = String.new
s_time_to = String.new
s_category = String.new
s_tags = String.new
s_place = String.new
s_desc = String.new

OptionParser.parse! do |parser|
  parser.banner = "Usage: salute [arguments]"

  # commands
  parser.on("-i", "--incoming", "List of incoming events") { |s|
    b_incoming = true
  }

  parser.on("-s ID", "--show=ID", "Show event details") { |s|
    b_show = true
    s_id = s
  }

  parser.on("-a NAME", "--add=NAME", "Add event") { |s|
    b_add = true
    s_name = s
  }

  # event params
  parser.on("-n NAME", "--name=NAME", "Name of event") { |s|
    s_name = s
  }

  parser.on("-f FROM", "--from=FROM", "Time from") { |s|
    s_time_from = s
  }

  parser.on("-t TO", "--to=TO", "Time to") { |s|
    s_time_to = s
  }

  parser.on("-p PLACE", "--place=PLACE", "Place") { |s|
    s_place = s
  }

  parser.on("-c TAGS", "--category=CATEGORY", "Category") { |s|
    s_category = s
  }

  parser.on("-g TAGS", "--tags=TAGS", "Tags ex: \"tag 1, tag 2\"") { |s|
    s_tags = s
  }

  parser.on("-d DESC", "--desc=DESC", "Desc") { |s|
    s_desc = s
  }

  parser.on("-F", "--force", "Add event") {
    b_force = true
  }

  # end
  parser.on("-h", "--help", "Show this help") { puts parser }
end

if b_add
  e = Ocranizer::Event.new
  e.name = s_name
  e.place = s_place
  e.desc = s_desc
  e.time_from_string = s_time_from
  e.time_to_string = s_time_to
  e.category = s_category
  e.tags_string = s_tags

  puts e.to_s_full

  if e.valid?
    if e.duplicate?
      # valid, but duplicate
      if b_force
        puts "Duplicate, but add forced"
        e.save
      else
        puts "Duplicate, not saving"
      end
    else
      # valid and not duplicate
      e.save
    end
  end

end

if b_incoming
  Ocranizer::Collection.incoming.each do |e|
    puts e.to_s_inline
  end
end

if b_show
  e = Ocranizer::Collection.get(id: s_id)
  puts e.to_s_full
end
