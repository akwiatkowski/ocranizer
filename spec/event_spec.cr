require "./spec_helper"

describe Ocranizer::Event do
  it "parse human `time_to` to full_day if `time_from` was full_day" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from" => "2017-05-05",
      "time_to"   => "next 2 days",
    })

    e.time_from.fullday?.should be_true
    e.time_to.fullday?.should be_true
  end

  it "uses `time_from` as `time_to` if `time_to` is missing" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "name"      => "wholeday",
      "time_from" => "2017-01-01",
    })

    e.time_from.fullday?.should be_true
    e.time_to.fullday?.should be_true

    e.time_from.time.at_beginning_of_day.should eq e.time_to.time.at_beginning_of_day
    e.time_from.time.at_beginning_of_day.should eq e.time_to.time.at_beginning_of_day
  end

  it "has range time getters `time_from_to_time` and `time_to_to_time`" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "name"      => "wholeday",
      "time_from" => "2017-01-01",
      "time_to"   => "2017-01-01",
    })

    e.time_from_to_time.should eq e.time_from.time.at_beginning_of_day
    e.time_to_to_time.should eq e.time_to.time.at_end_of_day
  end
end
