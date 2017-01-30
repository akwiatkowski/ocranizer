require "option_parser"

require "./ocranizer/event"
require "./ocranizer/collection"
require "./ocranizer/html_generator"

COMMAND_INCOMING = 0

COMMAND_SEARCH_EVENT = 10
COMMAND_ADD_EVENT    = 12

COMMAND_SEARCH_TODO = 20
COMMAND_ADD_TODO    = 22

COMMAND_SHOW_DETAIL   = 30
COMMAND_UPDATE_DETAIL = 31

COMMAND_GENERATE_HTML = 40

command = COMMAND_INCOMING

# parameters of Event or Todo
params = Hash(String, String).new
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
  parser.on("-E NAME", "--add-event=NAME", "Add event") { |s|
    command = COMMAND_ADD_EVENT
    params["name"] = s
  }

  parser.on("-e", "--search-events", "Search events") { |s|
    command = COMMAND_SEARCH_EVENT
    params["name"] = s
  }

  parser.on("-T NAME", "--add-todo=NAME", "Add TODO") { |s|
    command = COMMAND_ADD_TODO
    params["name"] = s
  }

  parser.on("-t", "--search-todos", "Search events") { |s|
    command = COMMAND_SEARCH_TODO
    params["name"] = s
  }

  parser.on("-s ID", "--id=ID", "Show event/todo details") { |s|
    command = COMMAND_SHOW_DETAIL
    params["id"] = s
  }

  parser.on("-S ID", "--id=ID", "Update event/todo details") { |s|
    command = COMMAND_UPDATE_DETAIL
    params["id"] = s
  }

  parser.on("-i", "--incoming", "List of incoming events and todos") { |s|
    command = COMMAND_INCOMING
  }

  parser.on("-H", "--html", "Generate HTML") { |s|
    command = COMMAND_GENERATE_HTML
  }

  # params
  parser.on("-j ID", "--id=ID", "Filter by ID") { |s|
    params["id"] = s
  }

  parser.on("-n NAME", "--name=NAME", "Name of event/todo") { |s|
    params["name"] = s
  }

  parser.on("-a FROM", "--from=FROM", "Time from") { |s|
    params["time_from"] = s
  }

  parser.on("-z TO", "--to=TO", "Time to") { |s|
    params["time_to"] = s
  }

  parser.on("-d DAY", "--day=DAY", "Filter only events/todos for one day") { |s|
    params["day"] = s
  }

  parser.on("-p PLACE", "--place=PLACE", "Place") { |s|
    params["place"] = s
  }

  parser.on("-c CATEGORY", "--category=CATEGORY", "Category") { |s|
    params["category"] = s
  }

  parser.on("-g TAGS", "--tags=TAGS", "Tags ex: \"tag 1, tag 2\"") { |s|
    params["tags"] = s
  }

  parser.on("-c DESC", "--desc=DESC", "Desc") { |s|
    params["desc"] = s
  }

  parser.on("-b URL", "--url=URL", "URL") { |s|
    params["url"] = s
  }

  parser.on("-u USER", "--user=NAME", "Default user is blank. This allow you to have someone else events") { |s|
    params["user"] = s
  }

  parser.on("-F", "--force", "Force action") {
    params["force"] = "true"
  }
  # end of params

  # end
  parser.on("-h", "--help", "Show this help") {
    puts parser
    exit
  }
end

case command
when COMMAND_ADD_EVENT, COMMAND_ADD_TODO
  if COMMAND_ADD_EVENT == command
    e = Ocranizer::Event.new
  else
    e = Ocranizer::Todo.new
  end

  e.update_attributes(params)
  # `id` is made unique when adding to collection
  # so it must be getted there
  ne = e.save(force: "true" == params["force"]?)

  if ne
    e = ne.not_nil!
  end
  puts e.to_s_full
  # end
when COMMAND_SEARCH_EVENT, COMMAND_SEARCH_TODO
  c = Ocranizer::Collection.new
  c.load

  if COMMAND_SEARCH_EVENT == command
    array = c.events(params)
  else
    array = c.todos(params)
  end

  array.each do |e|
    puts e.to_s_inline
  end
when COMMAND_INCOMING
  c = Ocranizer::Collection.new
  c.load

  # events
  ie = c.incoming_events
  puts "Events (#{ie.size}/#{c.events.size}):"
  ie.each do |e|
    puts e.to_s_inline
  end

  # todos
  it = c.incoming_todos
  puts "TODOs (#{it.size}/#{c.todos.size}):"
  it.each do |e|
    puts e.to_s_inline
  end
when COMMAND_SHOW_DETAIL, COMMAND_UPDATE_DETAIL
  e = Ocranizer::Collection.get_event(params["id"])
  if e
    e.update_attributes(params) if COMMAND_UPDATE_DETAIL == command
    puts e.to_s_full
  end

  e = Ocranizer::Collection.get_todo(params["id"])
  if e
    e.update_attributes(params) if COMMAND_UPDATE_DETAIL == command
    puts e.to_s_full
  end
when COMMAND_GENERATE_HTML
  e = Ocranizer::Collection.new
  e.load

  g = Ocranizer::HtmlGenerator.new(e)
  g.make_it_so
end
