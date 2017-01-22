require "./ocranizer/collection"
require "./ocranizer/cli/add_event"

a = Ocranizer::Collection.new
a.load
e = a.last
e.show if e
