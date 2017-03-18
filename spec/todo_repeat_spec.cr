require "./spec_helper"

describe Ocranizer::Todo do
  it "create repeated Todo" do
    e = Ocranizer::Todo.new
    e.update_attributes({
      "time_to" => "2017-01-01",
      "repeat"  => "weekly",
    })

    e.is_repeated?.should eq(true)

    nes = e.repeated_entities(
      repeated_from: Time.new(2017, 1, 1),
      repeated_to: Time.new(2017, 2, 1)
    )

    nes.not_nil!.size.should eq(4 + 1) # initial + 4 more
  end

  it "create repeated Todo completed till one point" do
    e = Ocranizer::Todo.new
    e.update_attributes({
      "time_to" => "2017-01-01",
      "repeat"  => "weekly",
    })
    e.completed_at = Time.new(2017, 1, 18)

    e.is_repeated?.should eq(true)

    nes = e.repeated_entities(
      repeated_from: Time.new(2017, 1, 1),
      repeated_to: Time.new(2017, 2, 1)
    )

    nes.not_nil!.size.should eq(4 + 1) # initial + 4 more

    child_events = nes.not_nil!

    # 2017-01-01
    child_events[0].completed?.should eq(true)
    child_events[0].min_time.not_nil!.year.should eq(2017)
    child_events[0].min_time.not_nil!.month.should eq(1)
    child_events[0].min_time.not_nil!.day.should eq(1)

    # 2017-01-08
    child_events[1].completed?.should eq(true)
    child_events[1].min_time.not_nil!.year.should eq(2017)
    child_events[1].min_time.not_nil!.month.should eq(1)
    child_events[1].min_time.not_nil!.day.should eq(8)

    # 2017-01-15
    child_events[2].completed?.should eq(true)
    child_events[2].min_time.not_nil!.year.should eq(2017)
    child_events[2].min_time.not_nil!.month.should eq(1)
    child_events[2].min_time.not_nil!.day.should eq(15)

    # 2017-01-22
    child_events[3].completed?.should eq(false)
    child_events[3].min_time.not_nil!.year.should eq(2017)
    child_events[3].min_time.not_nil!.month.should eq(1)
    child_events[3].min_time.not_nil!.day.should eq(22)

    # 2017-01-29
    child_events[4].completed?.should eq(false)
    child_events[4].min_time.not_nil!.year.should eq(2017)
    child_events[4].min_time.not_nil!.month.should eq(1)
    child_events[4].min_time.not_nil!.day.should eq(29)
  end
end
