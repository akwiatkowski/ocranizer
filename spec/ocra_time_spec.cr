require "./spec_helper"

describe Ocranizer::OcraTime do
  it "parse HH:MM" do
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

  it "parse YYYY:mm:dd HH:MM" do
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

  it "parse YYYY:mm:dd" do
    [[2010, 10, 11]].each do |a|
      o = Ocranizer::OcraTime.parse_human("#{a[0]}-#{a[1]}-#{a[2]}")
      o.should be_truthy

      o.not_nil!.time.year.should eq(a[0])
      o.not_nil!.time.month.should eq(a[1])
      o.not_nil!.time.day.should eq(a[2])
    end
  end

  it "parse next day" do
    o = Ocranizer::OcraTime.parse_human("next day")
    o.should be_truthy

    t = o.not_nil!.time

    (Time.now - t < Time::Span.new(-24, 0, 0)).should be_true
    (Time.now - t > Time::Span.new(-24, -11, 0)).should be_true
  end

  it "add 1 month to January 30" do
    time = Time.new(2010, 1, 30)
    span = Ocranizer::OcraTime::MONTH_SPAN

    result = Ocranizer::OcraTime.add_relative_interval(time, span)

    ((result - time) >= Ocranizer::OcraTime::MONTH_SPAN).should be_true
  end
end
