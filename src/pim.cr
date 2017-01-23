require "option_parser"
require "./ocranizer/event"

OptionParser.parse! do |parser|
  parser.banner = "Usage: salute [arguments]"
  parser.on("-e STRING", "--add-event=STRING", "Add event string <time from>,<time to>,<title>[,<place>,<desc>]") { |s|
    e = Ocranizer::Event.add_from_command(s)
    e.show
  }
  parser.on("-h", "--help", "Show this help") { puts parser }
end
