require "./spec_helper"

describe Ocranizer::Todo do
  it "create repeated Todo" do
    e = Ocranizer::Todo.new
    e.update_attributes({
      "time_to" => "2017-01-01",
      "repeat"  => "weekly",
    })

    puts e.inspect
  end
end
