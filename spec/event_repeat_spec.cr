require "./spec_helper"

describe Ocranizer::Event do
  it "create repeated Event" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "name"      => "birthday",
      "time_from" => "2017-01-01",
      "time_to"   => "2017-01-01",
      "repeat"    => "yearly",
    })

    puts e.inspect
  end
end
