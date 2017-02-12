require "./spec_helper"

describe Ocranizer::Event do
  it "calculate simple repeatitions" do
    e = Ocranizer::Event.new
    e.update_attributes({
        "time_from" => "2017-05-05",
        "time_to" => "2017-05-05",
        "repeat_until" => "2017-10-10",
        "repeat_interval" => "2 months",
        "repeat_count" => "2"
    })


    pp e
  end
end
