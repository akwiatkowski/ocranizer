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
end
