require "./spec_helper"

describe Ocranizer::Event do
  it "iterate simple repeatitions (limited) for past Event" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-05-05",
      "time_to"         => "2000-05-05",
      "repeat_interval" => "1 months",
      "repeat_count"    => "2",
    })

    e.time_from.time.month.should eq(5)
    e.time_from.time.day.should eq(5)

    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(6)
    e.time_from.time.day.should eq(5)

    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(7)
    e.time_from.time.day.should eq(5)

    # repeat only 2 times, not ignore and dont change time ranges
    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(7)
    e.time_from.time.day.should eq(5)
  end

  it "iterate simple repeatitions (limited) for past Event with 2 monts interval" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-05-05",
      "time_to"         => "2000-05-05",
      "repeat_interval" => "2 months",
      "repeat_count"    => "2",
    })

    e.time_from.time.month.should eq(5)
    e.time_from.time.day.should eq(5)

    e.repeatition_iterate_time_ranges

    e.time_from.time.month.should eq(7)
    e.time_from.time.day.should eq(5)
  end

  it "iterate simple repeatitions (unlimited) " do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-01-05",
      "time_to"         => "2000-01-05",
      "repeat_interval" => "2 weeks",
    })

    tf = e.time_from

    # move 26 iterations - 2*26 weeks = 2*26*7 days
    26.times do
      e.repeatition_iterate_time_ranges
    end

    tf2 = e.time_from

    time_diff = tf2.time - tf.time
    time_diff.days.should eq(2*26*7)

    # move till now
    e.repeatition_iterate_until_now

    (e.time_from.time >= Time.now).should be_true
    (e.time_to.time >= Time.now).should be_true
  end

  it "get next entities untill time" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from"       => "2000-01-05",
      "time_to"         => "2000-01-05",
      "repeat_interval" => "2 weeks",
    })

    time = Time.new(2000, 3, 1)

    nes = e.next_entities_until(time)
    nes.size.should eq(4)
  end

  it "test real life example" do
    e = Ocranizer::Event.new
    e.update_attributes({
      "time_from" => "2017-01-05",
      "time_to"   => "2017-01-05",
      "name"      => "Bill",
      "repeat"    => "monthly",
    })

    time = Time.new(2017, 8, 1)

    nes = e.next_entities_until(time)
    nes.size.should eq(6)
  end
end
