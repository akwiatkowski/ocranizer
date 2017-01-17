class Ocranizer::Interface::EventWindow
  def initialize(@event : Ocranizer::Event)
    @full_window = NCurses.stdscr.as(NCurses::Window)
    md = @full_window.max_dimensions
    @max_height = md[0].as(Int32)
    @max_width = md[1].as(Int32)

    @window = NCurses::Window.new(@max_height - 1, @max_width, 1, 0)
  end

  def render
    @window.clear
    LibNCurses.mvwprintw(@window, 0, 0, "Event:")
    @window.refresh
  end
end
