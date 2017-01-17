require "./ocranizer/event"
require "./ocranizer/interface/main"

e = Ocranizer::Event.new

i = Ocranizer::Interface::Main.new
i.render_event_window(e)
sleep 1
i.stop
