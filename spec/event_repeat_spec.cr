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

    child_events[0].min_time.year.should eq(2017)
    child_events[1].min_time.year.should eq(2018)
  end
end
