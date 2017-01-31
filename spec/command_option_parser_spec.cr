require "./spec_helper"

def config_path
  "spec/tmp.yml"
end

def config_backup_path
  "spec/tmp.yml.bak"
end

def initial_config_array
  ["-C", config_path]
end

def clear_config
  File.delete(config_path) if File.exists?(config_path)
  File.delete(config_backup_path) if File.exists?(config_backup_path)
end

def parser_json
  return Ocranizer::CommandOptionParser.new(format: Ocranizer::CommandOptionParser::FORMAT_JSON)
end

def parser_cli
  return Ocranizer::CommandOptionParser.new(format: Ocranizer::CommandOptionParser::FORMAT_CLI)
end

describe Ocranizer::CommandOptionParser do
  Spec.before_each do
    clear_config
  end

  it "get list of events from empty config" do
    a = initial_config_array
    a += ["-e"]
    parser = parser_json
    result = parser.parse(input: a)

    json = JSON.parse(result.as(String))
    json.size.should eq 0
  end

  it "create simple Event" do
    # check if list is empty
    a = initial_config_array
    a += ["-e"]
    parser = parser_json
    result = parser.parse(input: a)

    json = JSON.parse(result.as(String))
    json.size.should eq 0

    # create event
    name = "Test event"
    a = initial_config_array
    a += ["-E", name, "-a", "2018-10-10", "-z", "2018-10-20"]
    parser = parser_json
    result = parser.parse(input: a)

    json = JSON.parse(result.as(String))
    json["name"].should eq name

    # check if list is empty
    a = initial_config_array
    a += ["-e"]
    parser = parser_json
    result = parser.parse(input: a)

    json = JSON.parse(result.as(String))
    # json.size.should eq 0

    puts json
  end
end
