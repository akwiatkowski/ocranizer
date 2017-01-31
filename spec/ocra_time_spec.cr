require "./spec_helper"

describe Ocranizer::OcraTime do
  it "parse 'HH:MM' format" do
    t = Time.now
    [[10, 20]].each do |a|
      o = Ocranizer::OcraTime.parse_human("#{a[0]}:#{a[1]}")
      o.should be_truthy

      o.not_nil!.time.year.should eq(t.year)
      o.not_nil!.time.month.should eq(t.month)
      o.not_nil!.time.day.should eq(t.day)
      o.not_nil!.time.hour.should eq(a[0])
      o.not_nil!.time.minute.should eq(a[1])
    end
  end

  it "parse 'YYYY:mm:dd HH:MM' format" do
    [[2010, 10, 11, 10, 20]].each do |a|
      o = Ocranizer::OcraTime.parse_human("#{a[0]}-#{a[1]}-#{a[2]} #{a[3]}:#{a[4]}")
      o.should be_truthy

      o.not_nil!.time.year.should eq(a[0])
      o.not_nil!.time.month.should eq(a[1])
      o.not_nil!.time.day.should eq(a[2])
      o.not_nil!.time.hour.should eq(a[3])
      o.not_nil!.time.minute.should eq(a[4])
    end
  end

  it "parse 'YYYY:mm:dd' format" do
    [[2010, 10, 11]].each do |a|
      o = Ocranizer::OcraTime.parse_human("#{a[0]}-#{a[1]}-#{a[2]}")
      o.should be_truthy

      o.not_nil!.time.year.should eq(a[0])
      o.not_nil!.time.month.should eq(a[1])
      o.not_nil!.time.day.should eq(a[2])
    end
  end

  it "parse 'next day' string" do
    o = Ocranizer::OcraTime.parse_human("next day")
    o.should be_truthy

    t = o.not_nil!.time

    (Time.now - t < Time::Span.new(-24, 0, 0)).should be_true
    (Time.now - t > Time::Span.new(-24, -11, 0)).should be_true
  end

  it "parse 'day' string (next is by default)" do
    o = Ocranizer::OcraTime.parse_human("day")
    o.should be_truthy

    t = o.not_nil!.time

    (Time.now - t < Time::Span.new(-24, 0, 0)).should be_true
    (Time.now - t > Time::Span.new(-24, -11, 0)).should be_true
  end

  it "parse 'next 2 days'" do
    o = Ocranizer::OcraTime.parse_human("next 2 days")
    o.should be_truthy

    t = o.not_nil!.time

    (Time.now - t < Time::Span.new(-48, 0, 0)).should be_true
    (Time.now - t > Time::Span.new(-48, -11, 0)).should be_true
  end

  it "parse '2 days'" do
    o = Ocranizer::OcraTime.parse_human("2 days")
    o.should be_truthy

    t = o.not_nil!.time

    (Time.now - t < Time::Span.new(-48, 0, 0)).should be_true
    (Time.now - t > Time::Span.new(-48, -11, 0)).should be_true
  end

  it "parse next hour" do
    o = Ocranizer::OcraTime.parse_human("next hour")
    o.should be_truthy

    t = o.not_nil!.time

    (Time.now - t < Time::Span.new(-1, 0, 0)).should be_true
    (Time.now - t > Time::Span.new(-1, -11, 0)).should be_true
  end

  it "add 1 month to January 30" do
    time = Time.new(2010, 1, 30)
    span = Ocranizer::OcraTime::MONTH_SPAN

    result = Ocranizer::OcraTime.add_relative_interval(time, span)

    ((result - time) >= Ocranizer::OcraTime::MONTH_SPAN).should be_true
  end

  it "conserve day when adding month multiple times" do
    day = 10
    time = Time.new(2010, 3, day)
    span = Ocranizer::OcraTime::MONTH_SPAN

    100.times do
      time = Ocranizer::OcraTime.add_relative_interval(time, span)
      time.day.should eq(day)
    end
  end

  it "parse wrong string" do
    o = Ocranizer::OcraTime.parse_human("error")
    o.should be_truthy
    o.not_nil!.error?.should be_true
    o.not_nil!.not_error?.should be_false
  end

  it "parse empty string" do
    o = Ocranizer::OcraTime.parse_human("")
    o.should be_truthy
    o.not_nil!.error?.should be_true
    o.not_nil!.not_error?.should be_false
  end

  it "use relative date for `HH:MM` time if available" do
    s = "10:20"
    t = Time.new(2018, 10, 10)
    o = Ocranizer::OcraTime.parse_human(string: s, base_time: t)

    o.should be_truthy
    o.not_nil!.error?.should be_false
    o.not_nil!.not_error?.should be_true
    o.not_nil!.time.year.should eq 2018
    o.not_nil!.time.month.should eq 10
    o.not_nil!.time.day.should eq 10
    o.not_nil!.time.hour.should eq 10
    o.not_nil!.time.minute.should eq 20
  end
end
