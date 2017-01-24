require "option_parser"

require "./ocranizer/event"
require "./ocranizer/collection"

b_incoming = false
b_add = false

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

  parser.on("-a NAME", "--add=NAME", "Add event") { |s|
    b_add = true
    s_name = s
  }

  # event params
  parser.on("-n FROM", "--name=NAME", "Name of event") { |s|
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

  e.show
end

#
# c = Ocranizer::Collection.new
# c.load
# events = c.incoming
# events.each do |e|
#   e.show_inline
# end
