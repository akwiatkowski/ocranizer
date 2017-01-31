require "option_parser"

require "./event"
require "./collection"
require "./html_generator"

class Ocranizer::CommandOptionParser
  COMMAND_NULL = 0

  COMMAND_SEARCH_EVENT = 10
  COMMAND_ADD_EVENT    = 12

  COMMAND_SEARCH_TODO = 20
  COMMAND_ADD_TODO    = 22

  COMMAND_SHOW_DETAIL   = 30
  COMMAND_UPDATE_DETAIL = 31
  COMMAND_DELETE        = 32

  COMMAND_GENERATE_HTML = 40

  FORMAT_CLI = 0
  FORMAT_JSON = 1

  @parser : OptionParser

  def initialize(@format = FORMAT_CLI)
    @command = COMMAND_NULL
    # parameters of Event or Todo
    @params = Hash(String, String).new

    @parser = OptionParser.new do |parser|
      parser.banner = "Usage: salute [arguments]"

      # commands
      parser.on("-E NAME", "--add-event=NAME", "Add event") { |s|
        @command = COMMAND_ADD_EVENT
        @params["name"] = s
      }

      parser.on("-e", "--search-events", "Search events") { |s|
        @command = COMMAND_SEARCH_EVENT
        @params["name"] = s
      }

      parser.on("-T NAME", "--add-todo=NAME", "Add TODO") { |s|
        @command = COMMAND_ADD_TODO
        @params["name"] = s
      }

      parser.on("-t", "--search-todos", "Search events") { |s|
        @command = COMMAND_SEARCH_TODO
        @params["name"] = s
      }

      parser.on("-s ID", "--id=ID", "Show event/todo details") { |s|
        @command = COMMAND_SHOW_DETAIL
        @params["id"] = s
      }

      parser.on("-S ID", "--id=ID", "Update event/todo details") { |s|
        @command = COMMAND_UPDATE_DETAIL
        @params["id"] = s
      }

      parser.on("-D ID", "--delete=ID", "Delete event/todo") { |s|
        @command = COMMAND_DELETE
        @params["id"] = s
      }

      parser.on("-H", "--html", "Generate HTML") {
        @command = COMMAND_GENERATE_HTML
      }

      parser.on("-C PATH", "--config PATH", "Specify config path") { |s|
        Ocranizer::Collection.path = s
      }

      # params
      parser.on("-j ID", "--id=ID", "Filter by ID") { |s|
        @params["id"] = s
      }

      parser.on("-n NAME", "--name=NAME", "Name of event/todo") { |s|
        @params["name"] = s
      }

      parser.on("-a FROM", "--from=FROM", "Time from") { |s|
        @params["time_from"] = s
      }

      parser.on("-z TO", "--to=TO", "Time to") { |s|
        @params["time_to"] = s
      }

      parser.on("-d DAY", "--day=DAY", "Filter only events/todos for one day") { |s|
        @params["day"] = s
      }

      parser.on("-p PLACE", "--place=PLACE", "Place") { |s|
        @params["place"] = s
      }

      parser.on("-c CATEGORY", "--category=CATEGORY", "Category") { |s|
        @params["category"] = s
      }

      parser.on("-g TAGS", "--tags=TAGS", "Tags ex: \"tag 1, tag 2\"") { |s|
        @params["tags"] = s
      }

      parser.on("-c DESC", "--desc=DESC", "Desc") { |s|
        @params["desc"] = s
      }

      parser.on("-b URL", "--url=URL", "URL") { |s|
        @params["url"] = s
      }

      parser.on("-u USER", "--user=NAME", "Default user is blank. This allow you to have someone else events") { |s|
        @params["user"] = s
      }

      parser.on("-F", "--force", "Force action") {
        @params["force"] = "true"
      }
      # end of params

      # end
      parser.on("-h", "--help", "Show this help") {
        puts parser
        exit
      }
    end
  end

  def parse(input = ARGV)
    @parser.parse(input)

    return execute_after_parse
  end

  def cli?
    @format == FORMAT_CLI
  end

  def json?
    @format == FORMAT_JSON
  end

  def render_detailed_entity(e)
    if cli?
      return e.to_s_full
    end

    if json?
      return e.to_json
    end
  end

  def render_array_of_entities(array)
    if cli?
      return String.build do |str|
        array.each do |e|
          str << e.to_s_inline
          str << "\n"
        end
      end
    end

    if json?
      return array.to_json
    end
  end

  private def execute_after_parse
    case @command
    when COMMAND_ADD_EVENT, COMMAND_ADD_TODO
      c = Ocranizer::Collection.new
      c.load

      if COMMAND_ADD_EVENT == @command
        e = Ocranizer::Event.new
      else
        e = Ocranizer::Todo.new
      end

      e.update_attributes(@params)
      # `id` is made unique when adding to collection
      # so it must be getted there
      ne = c.add(entity: e, force: "true" == @params["force"]?)

      if ne
        # was added, valid and not duplicate
        # save to config file
        c.save
        # return
        e = ne.not_nil!
        return render_detailed_entity(e)
      end

      return nil
      # end
    when COMMAND_SEARCH_EVENT, COMMAND_SEARCH_TODO
      c = Ocranizer::Collection.new
      c.load

      if COMMAND_SEARCH_EVENT == @command
        array = c.events(@params)
      else
        array = c.todos(@params)
      end

      return render_array_of_entities(array)
    when COMMAND_SHOW_DETAIL, COMMAND_UPDATE_DETAIL
      c = Ocranizer::Collection.new
      c.load

      e = c.get_event(@params["id"])
      if e
        e.update_attributes(@params) if COMMAND_UPDATE_DETAIL == @command
        return render_detailed_entity(e)
      end

      e = c.get_todo(@params["id"])
      if e
        e.update_attributes(@params) if COMMAND_UPDATE_DETAIL == @command
        return render_detailed_entity(e)
      end

      return nil
    when COMMAND_DELETE
      c = Ocranizer::Collection.new
      c.load
      e = c.get_event(@params["id"])
      if e
        c.remove(e)
        c.save
        return render_detailed_entity(e)
      end

      e = c.get_todo(@params["id"])
      if e
        c.remove(e)
        c.save
        return render_detailed_entity(e)
      end

      return nil
    when COMMAND_GENERATE_HTML
      e = Ocranizer::Collection.new
      e.load

      g = Ocranizer::HtmlGenerator.new(collection: e, params: @params)
      g.make_it_so
    end
  end
end
