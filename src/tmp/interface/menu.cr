class Ocranizer::Interface::Menu
  def initialize(@max_width : Int32)
    @menu = NCurses::Window.new(1, @max_width, 0, 0)
  end

  def render
    @menu.clear
    LibNCurses.mvwprintw(@menu, 0, 0, "Menu")
    @menu.refresh
  end
end
