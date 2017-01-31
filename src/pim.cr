require "option_parser"

require "./ocranizer/command_option_parser"

c = CommandOptionParser.new
c.parse(input: ARGV)
c.execute_after_parse
