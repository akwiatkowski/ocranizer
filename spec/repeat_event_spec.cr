require "./spec_helper"

describe Ocranizer::Event do
  it "iterate simple repeatitions for past Event" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-05-05",
      "time_to"         => "2000-05-05",
      "repeat_interval" => "1 months",
      "repeat_count"    => "2",
    })

    e.time_from.time.month.should eq(5)
    e.time_from.time.day.should eq(5)

    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(6)
    e.time_from.time.day.should eq(5)

    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(7)
    e.time_from.time.day.should eq(5)

    # repeat only 2 times, not ignore and dont change time ranges
    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(7)
    e.time_from.time.day.should eq(5)
  end

  it "iterate simple repeatitions for past Event with 2 monts interval" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-05-05",
      "time_to"         => "2000-05-05",
      "repeat_interval" => "2 months",
      "repeat_count"    => "2",
    })

    e.time_from.time.month.should eq(5)
    e.time_from.time.day.should eq(5)

    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(7)
    e.time_from.time.day.should eq(5)
  end

  # it "iterate simple repeatitions for past Event" do
  #   e = Ocranizer::Event.new
  #   e.update_attributes({
  #     "time_from"       => "2000-05-05",
  #     "time_to"         => "2000-05-05",
  #     "repeat_until"    => "2017-10-10",
  #     "repeat_interval" => "2 months",
  #     "repeat_count"    => "2",
  #   })
  #
  #   pp e
  # end
end
