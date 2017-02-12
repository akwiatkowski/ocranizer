require "./spec_helper"

describe Ocranizer::Todo do
  it "parse human `time_to` to full_day if `time_from` was full_day" do
    e = Ocranizer::Todo.new
    e.update_attributes({
      "time_from" => "2017-05-05",
      "time_to"   => "next 2 days",
    })

    e.time_from.not_nil!.fullday?.should be_true
    e.time_to.not_nil!.fullday?.should be_true
  end
end
