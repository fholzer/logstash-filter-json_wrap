# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/json_wrap"

describe LogStash::Filters::JsonWrap do
  describe "Ensure " do
    let(:config) do <<-CONFIG
      filter {
        json_wrap {
          exclude => ["@timestamp", "@metadata", "@version", "even"]
          target => "dst"
          add_field => { "success" => "success" }
        }
      }
    CONFIG
    end

    hash1 = {
      "app" => "someapp",
      "testkey" => "testvalue"
    }
    hash2 = {
      "app" => "someapp",
      "testkey" => "testvalue",
      "even" => "more"
    }

    sample(hash1) do
      expect(subject).to include("success")
      expect(subject).not_to include("app")
      expect(subject).not_to include("tags")
      expect(subject).to include("dst")
      h = LogStash::Json.load(subject.get('dst'))
      expect(h).to eq(hash1)
    end

    sample(hash2) do
      expect(subject).to include("success")
      expect(subject).not_to include("app")
      expect(subject).not_to include("tags")
      expect(subject).to include("dst")
      h = LogStash::Json.load(subject.get('dst'))
      expect(h).to eq(hash1)
    end

  end
end
