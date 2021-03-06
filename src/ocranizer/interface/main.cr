require "ncurses"

require "./menu"
require "./event_window"

# https://github.com/akwiatkowski/idle_crystal/tree/master/src/idle_crystal/interface
# https://github.com/jreinert/ncurses-crystal
# https://github.com/agatan/ncurses.cr

class Ocranizer::Interface::Main
  COLOR_DEFAULT = 0
  COLOR_GREEN   = 1
  COLOR_RED     = 2
  COLOR_BLUE    = 3

  def initialize
    @enabled = true

    NCurses.init
    NCurses.raw
    NCurses.no_echo
    NCurses.start_color

    LibNCurses.init_pair(COLOR_GREEN, 2, 0)
    LibNCurses.init_pair(COLOR_BLUE, 3, 0)
    LibNCurses.init_pair(COLOR_RED, 1, 0)

    @window = NCurses.stdscr.as(NCurses::Window)
    md = @window.max_dimensions
    @max_height = md[0].as(Int32)
    @max_width = md[1].as(Int32)

    @menu = Ocranizer::Interface::Menu.new(max_width: @max_width)
    @menu.render
  end

  def stop
    NCurses.end_win
  end

  def wait_for_input
    @window.timeout = 0.2
    char = @window.get_char
    case char
    # when 68
    #   @content_manager.prev_tab
    #   refresh
    # when 67
    #   @content_manager.next_tab
    #   refresh
    # when 65
    #   @content_manager.prev_page
    #   refresh
    # when 66
    #   @content_manager.next_page
    #   refresh

    when 'q'
      @enabled = false
    end

    return char
  end

  def render_event_form
    e = Ocranizer::Event.new
    ew = EventWindow.new(e)
    while @enabled
      key = wait_for_input
      ew.render
      ew.send_key(key)
      sleep 0.02
    end
  end

  def render_event_window(event : Ocranizer::Event)
  end
end
