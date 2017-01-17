struct Ocranizer::Event
  def initialize
    @time_from = Time.now
    @time_to = (@time_from + Time::Span.new(1, 0, 0)).as(Time)
  end

  getter :time_from, :time_to
end
