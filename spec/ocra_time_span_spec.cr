require "./spec_helper"

describe Ocranizer::OcraTimeSpan do
  it "create simple OcraTimeSpan (week) and add it to Time" do
    t = Time.new(
      2010, 1, 2, 3, 4
    )

    s = Ocranizer::OcraTimeSpan.new(string: "next week")
    ta = s + t
    tb = t + s

    ta.day_of_week.should eq(t.day_of_week)
    tb.day_of_week.should eq(t.day_of_week)

    ta.year.should eq(t.year)
    tb.year.should eq(t.year)

    ta.month.should eq(t.month)
    tb.month.should eq(t.month)
  end

  it "create simple OcraTimeSpan (year) and add it to Time" do
    t = Time.new(
      2010, 1, 2, 3, 4
    )

    s = Ocranizer::OcraTimeSpan.new(string: "next year")
    ta = s + t
    tb = t + s

    ta.year.should eq(t.year + 1)
    tb.year.should eq(t.year + 1)

    ta.month.should eq(t.month)
    tb.month.should eq(t.month)
  end
end
