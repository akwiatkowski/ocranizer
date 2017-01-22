require "./ocranizer/event"
require "./ocranizer/collection"
require "./ocranizer/ocra_time"

require "./ocranizer/cli/add_event"

a = Ocranizer::Cli::AddEvent.new
a.get_data
a.store
