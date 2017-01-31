require "./ocranizer"

c = Ocranizer::CommandOptionParser.new
puts c.parse(input: ARGV)
