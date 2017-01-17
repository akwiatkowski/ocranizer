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

    # o.not_nil!.time.year.should eq(a[0])
    # o.not_nil!.time.month.should eq(a[1])
    # o.not_nil!.time.day.should eq(a[2])
  end


end
