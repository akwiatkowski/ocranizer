class Ocranizer::HtmlGenerator
  OUTPUT_PATH = Ocranizer::Collection::PATH + ".html"

  def initialize(@collection : Ocranizer::Collection, @params : Hash(String, String))
    @events = @collection.events(params: params).as(Array(Ocranizer::Event))
    @todos = @collection.todos(params: params).as(Array(Ocranizer::Todo))
  end

  def make_it_so
    f = File.new(OUTPUT_PATH, "w")
    f.puts(html)
    f.close

    open_in_browser
  end

  def open_in_browser
    command = "xdg-open file:#{OUTPUT_PATH}"
    # puts command
    `#{command}`
  end

  def html
    str = String.build do |str|
      str << "<html>"
      str << "<head>"
      html_head(str)
      str << "</head>"
      str << "<body>"
      html_body(str)
      str << "</body>"
      str << "</html>"
    end
    return str
  end

  private def html_head(str)
    cell_width = 300

    str << "<meta charset=\"UTF-8\">"
    str << "<title>Ocranizer</title>"
    str << "<style media=\"screen\" type=\"text/css\">"
    # http://mincss.com/
    str << "body,textarea,input,select{background:0;border-radius:0;font:16px sans-serif;margin:0}.addon,.btn-sm,.nav,textarea,input,select{outline:0;font-size:14px}.smooth{transition:all .2s}.btn,.nav a{text-decoration:none}.container{margin:0 20px;width:auto}@media(min-width:1310px){.container{margin:auto;width:1270px}}.btn,h2{font-size:2em}h1{font-size:3em}.btn{background:#999;border-radius:6px;border:0;color:#fff;cursor:pointer;display:inline-block;margin:2px 0;padding:12px 30px 14px}.btn:hover{background:#888}.btn:active,.btn:focus{background:#777}.btn-a{background:#0ae}.btn-a:hover{background:#09d}.btn-a:active,.btn-a:focus{background:#08b}.btn-b{background:#3c5}.btn-b:hover{background:#2b4}.btn-b:active,.btn-b:focus{background:#2a4}.btn-c{background:#d33}.btn-c:hover{background:#c22}.btn-c:active,.btn-c:focus{background:#b22}.btn-sm{border-radius:4px;padding:10px 14px 11px}label>*{display:inline}form>*{display:block;margin-bottom:10px}textarea,input,select{border:1px solid #ccc;padding:8px}textarea:focus,input:focus,select:focus{border-color:#5ab}textarea,input[type=text]{-webkit-appearance:none;width:13em;outline:0}.addon{box-shadow:0 0 0 1px #ccc;padding:8px 12px}"
    # custom
    str << ".calendar-day{width: #{cell_width}px;height: 100px;border: 1px dotted #888; color: #000; position: relative; padding: 20px 4px 4px 4px; margin: 2px; }"
    str << ".calendar-day .day{position: absolute; top: 3px; left: 3px; font-size: 120%}"
    str << ".calendar-day.day-other-month{border: 1px dotted #eee;color: #999; background-color: #eee}"
    str << ".calendar-day.day-5{border: 1px dotted #2a2; background-color: #fafffa}"
    str << ".calendar-day.day-6{border: 1px dotted #f55; background-color: #fdd}"
    str << ".calendar-day.day-has-entities{border-style: solid;}"
    str << ".calendar-day .entity-time{font-size: 60%}"
    str << "a{color: #55a;}"
    str << "</style>"
    # TODO add https://github.com/kenwheeler/cash/
  end

  private def html_body(str)
    str << "<h1>Ocranizer</h1>"
    html_calendar(str)
  end

  private def html_calendar(str)
    t_from = Time.now.at_beginning_of_month
    t_tos = Array(Time).new
    t_tos << Time.now.at_end_of_month

    t_tos += @events.map(&.time_to).map(&.time)
    t_tos += @todos.map(&.time_to).select { |t| t }.map { |t| t.not_nil!.time }
    t_to = t_tos.max.as(Time)
    t_to = t_to.at_end_of_month

    str << "<h2>#{t_from.to_s("%Y-%m-%d")} - #{t_to.to_s("%Y-%m-%d")}</h2>"

    t = t_from
    while t < t_to
      html_per_month(str, month: t)

      t = t.at_end_of_month + Time::Span.new(1, 0, 0)
    end
  end

  private def html_per_month(str, month : Time)
    str << "<h3>#{month.to_s("%Y-%m-%d")}</h2>"

    str << "<table class=\"table\">"

    str << "<thead><tr>"
    %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday).each do |weekday|
      str << "<th>#{weekday}</th>"
    end
    str << "</tr></thead><tbody>"

    t_start = month.at_beginning_of_week
    t = t_start

    while t <= month.at_end_of_month
      # week loop

      str << "<tr>"

      (0..6).each do |day|
        # day loop
        cell_time = t + Time::Span.new(24 * day, 0, 0)

        klass = ""
        # make outside days grayish
        if cell_time.month != month.month
          klass += " day-other-month"
        end

        # day with entities has lined border
        if (events_for_day(cell_time).size + todos_for_day(cell_time).size) > 0
          klass += " day-has-entities"
        end

        str << "<td class=\"calendar-day day-#{day} #{klass}\" data-time=\"#{cell_time.to_s("%Y-%m-%d")}\">"
        html_per_day(str, day: cell_time, month: month)
        str << "</td>"
      end

      str << "</tr>"

      t += Time::Span.new(24 * 7, 0, 0)
    end

    str << "</tbody></table>"
  end

  def events_for_day(day : Time)
    @events.select { |e| e.is_within?(day) }
  end

  def todos_for_day(day : Time)
    @todos.select { |e| e.is_within?(day) }
  end

  private def html_per_day(str, day : Time, month : Time)
    str << "<div class=\"day\">#{day.to_s("%d")}</div>"

    events_for_day(day).each do |event|
      html_per_entity(str, event)
    end

    todos_for_day(day).each do |event|
      html_per_entity(str, event)
    end
  end

  private def html_per_entity(str, entity : (Ocranizer::Event | Ocranizer::Todo) )
    category_klass = "category-#{entity.category}"
    category_klass = "category-blank" if entity.category.to_s == ""

    str << "<div class=\"entity #{category_klass}\">"

    str << "<span class=\"entity-time\">"
    if entity.time_from && entity.time_from.not_nil!.not_full_day?
      str << entity.time_from.not_nil!.time.to_s("%H:%M")
    end

    if entity.time_to && entity.time_to.not_nil!.not_full_day?
      str << " - "
      str << entity.time_to.not_nil!.time.to_s("%H:%M")
    end
    str << "</span>"

    str << " "

    if entity.url.to_s != ""
      str << "<a href=\"#{entity.url}\" target=\"_blank\">"
      str << "#{entity.name}"
      str << "</a>"
    else
      str << "#{entity.name}"
    end

    str << "</div>"
  end
end
