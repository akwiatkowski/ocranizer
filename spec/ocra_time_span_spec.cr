require "./spec_helper"

describe Ocranizer::OcraTimeSpan do
  it "create simple OcraTimeSpan (week) and add it to Time" do
    t = Time.new(
      year: 2010,
      month: 1,
      day: 2,
      hour: 3,
      minute: 4,
      kind: Time::Kind::Local
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
      year: 2010,
      month: 1,
      day: 2,
      hour: 3,
      minute: 4,
      kind: Time::Kind::Local
    )

    s = Ocranizer::OcraTimeSpan.new(string: "next year")
    ta = s + t
    tb = t + s

    ta.year.should eq(t.year + 1)
    tb.year.should eq(t.year + 1)

    ta.month.should eq(t.month)
    tb.month.should eq(t.month)
  end

  it "create simple OcraTimeSpan (month) and add it to Time" do
    t = Time.new(
      year: 2010,
      month: 1,
      day: 2,
      hour: 3,
      minute: 4,
      kind: Time::Kind::Local
    )

    s = Ocranizer::OcraTimeSpan.new(string: "1 months")
    ta = s + t
    tb = t + s

    ta.year.should eq(t.year)
    tb.year.should eq(t.year)

    ta.month.should eq(2)
    tb.month.should eq(2)

    ta.day.should eq(2)
    tb.day.should eq(2)
  end
end
