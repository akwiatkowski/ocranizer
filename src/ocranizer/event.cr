struct Ocranizer::Event
  @time_from : OcraTime
  @time_to : OcraTime

  def initialize
    @time_from = OcraTime.new_time_from
    @time_to = OcraTime.new_time_to
  end

  property :time_from, :time_to
end
