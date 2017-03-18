require "./spec_helper"

describe Ocranizer::Event do
  it "create repeated Event and get dynamicaly created events for 2 years" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "name"      => "birthday",
      "time_from" => "2017-01-01",
      "time_to"   => "2017-01-01",
      "repeat"    => "yearly",
    })

    child_events = e.repeated_entities(
      repeated_from: Time.new(2017, 1, 1),
      repeated_to: Time.new(2018, 12, 1)
    ).not_nil!

    child_events.size.should eq(2)

    child_events[0].min_time.not_nil!.year.should eq(2017)
    child_events[1].min_time.not_nil!.year.should eq(2018)
  end

  it "get events untill time" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-01-05",
      "time_to"         => "2000-01-05",
      "repeat_interval" => "2 weeks",
    })

    nes = e.repeated_entities(
      repeated_from: e.time_from.time,
      repeated_to: Time.new(2000, 3, 1)
    ).not_nil!
    nes.size.should eq(4 + 1) # initial + 4 more
  end

  it "test real life example" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from" => "1960-10-10",
      "time_to"   => "1960-10-10",
      "name"      => "Birthday",
      "repeat"    => "yearly",
    })

    nes = e.repeated_entities(
      repeated_from: e.time_from.time,
      repeated_to: Time.new(2017, 10, 1)
    ).not_nil!
    nes.size.should eq(56 + 1)
  end
end
