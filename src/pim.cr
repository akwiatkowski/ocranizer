require "option_parser"

require "./ocranizer/event"
require "./ocranizer/collection"

COMMAND_INCOMING = 0
COMMAND_SHOW_EVENT = 1
COMMAND_ADD_EVENT = 2
COMMAND_SHOW_TODO = 3
COMMAND_ADD_TODO = 4
COMMAND_SHOW_ALL = 5

command = COMMAND_INCOMING

# parameters of Event or Todo
s_id = String.new
s_name = String.new
s_time_from = String.new
s_time_to = String.new
s_category = String.new
s_tags = String.new
s_place = String.new
s_desc = String.new

b_force = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: salute [arguments]"

  # commands
  parser.on("-i", "--incoming", "List of incoming events/todos") { |s|
    command = COMMAND_INCOMING
  }

  parser.on("-s ID", "--show=ID", "Show event details") { |s|
    command = COMMAND_SHOW_EVENT
    s_id = s
  }

  parser.on("-v", "--show-all", "Show all") {
    command = COMMAND_SHOW_ALL
  }

  parser.on("-a NAME", "--add-event=NAME", "Add event") { |s|
    command = COMMAND_ADD_EVENT
    s_name = s
  }

  parser.on("-b NAME", "--add-todo=NAME", "Add TODO") { |s|
    command = COMMAND_ADD_TODO
    s_name = s
  }

  # params
  parser.on("-n NAME", "--name=NAME", "Name of event/todo") { |s|
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

  parser.on("-F", "--force", "Force action") {
    b_force = true
  }
  # end of params

  # end
  parser.on("-h", "--help", "Show this help") { puts parser }
end

case command
when COMMAND_ADD_EVENT, COMMAND_ADD_TODO then
  if COMMAND_ADD_EVENT == command
    e = Ocranizer::Event.new
  else
    e = Ocranizer::Todo.new
  end

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

if COMMAND_INCOMING == command
  Ocranizer::Collection.incoming_events.each do |e|
    puts e.to_s_inline
  end

  Ocranizer::Collection.incoming_todos.each do |e|
    puts e.to_s_inline
  end
end

if COMMAND_SHOW_EVENT == command
  e = Ocranizer::Collection.get_event(id: s_id)
  puts e.to_s_full
end

if COMMAND_SHOW_TODO == command
  e = Ocranizer::Collection.get_todo(id: s_id)
  puts e.to_s_full
end

if COMMAND_SHOW_ALL == command
  c = Ocranizer::Collection.new
  c.load

  puts "Events (#{c.events.size}):"
  c.events.each do |e|
    puts e.to_s_inline
  end

  puts "Todos (#{c.todos.size}): "
  c.todos.each do |e|
    puts e.to_s_inline
  end
end
