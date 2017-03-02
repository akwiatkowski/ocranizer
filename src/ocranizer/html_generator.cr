class Ocranizer::HtmlGenerator
  def self.output_path
    return Ocranizer::Collection.path + ".html"
  end

  def initialize(
                 @collection : Ocranizer::Collection,
                 @params : Hash(String, String))
    @events = @collection.events(params: params).as(Array(Ocranizer::Event))
    @todos = @collection.todos(params: params).as(Array(Ocranizer::Todo))
    @notes = @collection.notes(params: params).as(Array(Ocranizer::Note))

    @time_from = Ocranizer::OcraTime.now.at_beginning_of_month.as(Time)
    @time_to = calendar_time_to.as(Time)

    # repeated entities (only Event and Todo)
    repeated_entities = Array(Ocranizer::Entity).new

    @events.each do |event|
      repeated_entities += event.next_entities_until(time: @time_to)
    end
    @todos.each do |todo|
      repeated_entities += todo.next_entities_until(time: @time_to)
    end
    repeated_entities.each do |e|
      if e.as?(Ocranizer::Todo)
        @todos << e.as(Ocranizer::Todo)
      elsif e.as?(Ocranizer::Event)
        @events << e.as(Ocranizer::Event)
      end
    end
  end

  def make_it_so
    f = File.new(self.class.output_path, "w")
    f.puts(html)
    f.close

    open_in_browser
  end

  def open_in_browser
    command = "xdg-open file:#{self.class.output_path}"
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
    str << "<title>Ocranizer, generated #{Ocranizer::OcraTime.now.to_s("%Y-%m-%d %H:%M:%S")}</title>"
    str << "<style media=\"screen\" type=\"text/css\">"
    # http://mincss.com/
    str << "body,textarea,input,select{background:0;border-radius:0;font:16px sans-serif;margin:0}.addon,.btn-sm,.nav,textarea,input,select{outline:0;font-size:14px}.smooth{transition:all .2s}.btn,.nav a{text-decoration:none}.container{margin:0 20px;width:auto}@media(min-width:1310px){.container{margin:auto;width:1270px}}.btn,h2{font-size:2em}h1{font-size:3em}.btn{background:#999;border-radius:6px;border:0;color:#fff;cursor:pointer;display:inline-block;margin:2px 0;padding:12px 30px 14px}.btn:hover{background:#888}.btn:active,.btn:focus{background:#777}.btn-a{background:#0ae}.btn-a:hover{background:#09d}.btn-a:active,.btn-a:focus{background:#08b}.btn-b{background:#3c5}.btn-b:hover{background:#2b4}.btn-b:active,.btn-b:focus{background:#2a4}.btn-c{background:#d33}.btn-c:hover{background:#c22}.btn-c:active,.btn-c:focus{background:#b22}.btn-sm{border-radius:4px;padding:10px 14px 11px}label>*{display:inline}form>*{display:block;margin-bottom:10px}textarea,input,select{border:1px solid #ccc;padding:8px}textarea:focus,input:focus,select:focus{border-color:#5ab}textarea,input[type=text]{-webkit-appearance:none;width:13em;outline:0}.addon{box-shadow:0 0 0 1px #ccc;padding:8px 12px} "
    # custom
    str << "a{color: #55a;} "

    str << ".calendar-day{width: #{cell_width}px;height: 100px;border: 1px dotted #888; color: #000; position: relative; padding: 20px 4px 4px 4px; margin: 2px; } "
    str << ".calendar-day .day{position: absolute; top: 3px; left: 3px; font-size: 120%} "
    str << ".calendar-day.day-other-month{border: 1px dotted #eee;color: #999; background-color: #eee} "
    str << ".calendar-day.day-5{border: 1px dotted #2a2; background-color: #fafffa} "
    str << ".calendar-day.day-6{border: 1px dotted #f55; background-color: #fdd} "
    str << ".calendar-day.day-has-entities{border-style: solid;} "
    str << ".calendar-day.current-day{background-color: #555;color: #fff;} "
    str << ".calendar-day.current-day a{color: #fff;} "
    str << ".calendar-day .entity-time{font-size: 60%} "
    str << ".calendar-day .entity-place{font-size: 60%} "

    str << ".entity.priority-important {color: #f00; font-weight: 600} "
    str << ".entity.priority-important a{color: #f00; font-weight: 600} "
    str << ".entity.priority-urgent {color: #ff0; font-weight: 400} "
    str << ".entity.priority-urgent a{color: #ff0; font-weight: 400} "

    str << ".entity-list-item{position: relative; min-height: 100px; margin-bottom: 15px; padding: 5px; background-color: #eee;} "
    str << ".entity-list-item .entity-year{position: absolute; top: 5px; left: 0px; font-size: 60%; width: 80px; text-align: center} "
    str << ".entity-list-item .entity-month{position: absolute; top: 28px; left: 0px; font-size: 120%; width: 80px; text-align: center} "
    str << ".entity-list-item .entity-day{position: absolute; top: 55px; left: 0px; font-size: 220%; width: 80px; text-align: center} "
    str << ".entity-list-item .entity-name{top: 0px; left: 80px; position: relative; font-size: 120%; margin-bottom: 10px} "
    str << ".entity-list-item .entity-content{left: 80px; position: relative} "

    str << "</style>"
    # TODO add https://github.com/kenwheeler/cash/
    # TODO add https://github.com/flouthoc/uglipop.js/
  end

  private def html_per_entity(str, entity)
    klass = entity.class.to_s.downcase.gsub("ocranizer::", "")
    str << "<a name=\"#{entity.id}\"></a>"
    str << "<div class=\"entity-list-item #{klass}\">"

    str << "<div class=\"entity-name\">"
    str << entity.name
    str << "</div>"

    if entity.time_from
      str << "<div class=\"entity-day\">"
      str << entity.time_from.not_nil!.time.to_s("%d")
      str << "</div>"

      str << "<div class=\"entity-month\">"
      str << entity.time_from.not_nil!.time.to_s("%b")
      str << "</div>"

      str << "<div class=\"entity-year\">"
      str << entity.time_from.not_nil!.time.to_s("%Y")
      str << "</div>"
    elsif entity.time_to
      str << "<div class=\"entity-day\">"
      str << entity.time_to.not_nil!.time.to_s("%d")
      str << "</div>"

      str << "<div class=\"entity-month\">"
      str << entity.time_to.not_nil!.time.to_s("%b")
      str << "</div>"

      str << "<div class=\"entity-year\">"
      str << entity.time_to.not_nil!.time.to_s("%Y")
      str << "</div>"
    end

    str << "<div class=\"entity-content\">"

    if entity.time_from
      str << "Time from: "
      str << entity.time_from.not_nil!.time.to_s("%Y-%m-%d %H:%M")
      str << "</br>"
    end

    if entity.time_to
      str << "Time to: "
      str << entity.time_to.not_nil!.time.to_s("%Y-%m-%d %H:%M")
      str << "</br>"
    end

    if entity.place.to_s.size > 0
      str << "Place: "
      str << entity.place
      str << "</br>"
    end

    if entity.desc.to_s.size > 0
      str << "Desc: "
      str << "</br>"
      str << entity.desc.gsub(/\n/, "</br>").gsub(/\\n/, "</br>")
      str << "</br>"
      str << "</br>"
    end

    if entity.category.to_s.size > 0
      str << "Category: "
      str << entity.category
      str << "</br>"
    end

    if entity.tags.size > 0
      str << "Tags: "
      str << entity.tags.join(", ")
      str << "</br>"
    end

    if entity.url.to_s.size > 0
      str << "URL: "
      str << "<a href=\"#{entity.url}\" target=\"_blank\">"
      str << entity.url
      str << "</a>"
      str << "</br>"
    end

    if entity.user.to_s.size > 0
      str << "User: "
      str << entity.user
      str << "</br>"
    end

    str << "ID: "
    str << entity.id
    str << "</br>"

    str << "Command params: "
    str << entity.to_command_parameters
    str << "</br>"

    str << "</div>"
    # end of content div

    str << "</div>"
  end

  private def html_per_note(str, note)
    klass = note.class.to_s.downcase.gsub("ocranizer::", "")
    str << "<a name=\"#{note.id}\"></a>"
    str << "<div class=\"entity-list-item #{klass}\">"

    str << "<div class=\"entity-name\">"
    str << note.name
    str << "</div>"

    str << "<div class=\"entity-day\">"
    str << note.created_at.to_s("%d")
    str << "</div>"

    str << "<div class=\"entity-month\">"
    str << note.created_at.to_s("%b")
    str << "</div>"

    str << "<div class=\"entity-year\">"
    str << note.created_at.to_s("%Y")
    str << "</div>"

    str << "<div class=\"entity-content\">"

    # note name is alias of content
    # str << note.content
    # str << "</br>"

    str << "<span class=\"small\">"
    str << "ID: "
    str << note.id
    str << "</span>"
    str << "</br>"

    str << "</div>"
    # end of content div

    str << "</div>"
  end

  private def html_body(str)
    str << "<h1>Ocranizer</h1>"
    html_calendar(str)
    str << "<h2>Events</h2>"
    html_events(str)
    str << "<h2>Todos</h2>"
    html_todos(str)
    str << "<h2>Notes</h2>"
    html_notes(str)
  end

  private def html_events(str)
    @events.each do |event|
      html_per_entity(str, event)
    end
  end

  private def html_todos(str)
    @todos.each do |event|
      html_per_entity(str, event)
    end
  end

  private def html_notes(str)
    @notes.each do |note|
      html_per_note(str, note)
    end
  end

  private def calendar_time_to
    t_tos = Array(Time).new
    t_tos << Ocranizer::OcraTime.now.at_end_of_month

    t_tos += @events.map(&.time_to).map(&.time)
    t_tos += @todos.map(&.time_to).select { |t| t }.map { |t| t.not_nil!.time }
    t_to = t_tos.max.as(Time)
    t_to = t_to.at_end_of_month
    return t_to
  end

  private def html_calendar(str)
    str << "<h2>#{@time_from.to_s("%Y-%m-%d")} - #{@time_to.to_s("%Y-%m-%d")}</h2>"

    t = @time_from
    while t < @time_to
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

        t_now = Ocranizer::OcraTime.now
        if t_now.year == cell_time.year &&
           t_now.month == cell_time.month &&
           t_now.day == cell_time.day &&
           month.month == cell_time.month # only for current month
          klass += " current-day"
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
      html_cell_per_entity(str, event)
    end

    todos_for_day(day).each do |todo|
      html_cell_per_entity(str, todo)
    end
  end

  private def html_cell_per_entity(str, entity : (Ocranizer::Event | Ocranizer::Todo))
    category_klass = "category-#{entity.category}"
    category_klass = "category-blank" if entity.category.to_s == ""

    if entity.important?
      category_klass += " priority-important"
    elsif entity.urgent?
      category_klass += " priority-urgent"
    elsif entity.low_priority?
      category_klass += " priority-low"
    end

    str << "<div class=\"entity #{category_klass}\">"

    # is completed
    if entity.completed?
      str << "<input type=\"checkbox\" checked disabled=\"disabled\" title=\"#{entity.completed_at.not_nil!.to_s("%Y-%m-%d %H:%M")}\">"
    end

    str << "<span class=\"entity-time\">"
    if entity.time_from && entity.time_from.not_nil!.not_fullday?
      str << entity.time_from.not_nil!.time.to_s("%H:%M")
    end

    if entity.time_to && entity.time_to.not_nil!.not_fullday?
      str << " - "
      str << entity.time_to.not_nil!.time.to_s("%H:%M")
    end
    str << "</span>"

    str << " "

    str << "<a href=\"##{entity.id}\">"
    str << "#{entity.name}"
    str << "</a>"

    if entity.place.to_s != ""
      str << " "
      str << "<span class=\"entity-place\">"
      str << "("
      str << entity.place
      str << ")"
      str << "</span> "
    end

    str << "</div>"
  end
end
