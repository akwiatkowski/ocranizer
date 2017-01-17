require "./ocranizer/event"
require "./ocranizer/interface/main"

i = Ocranizer::Interface::Main.new
i.render_event_form
i.stop
