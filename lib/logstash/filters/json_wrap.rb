# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::JsonWrap < LogStash::Filters::Base
  config_name "json_wrap"

  # Fields not to wrap.
  config :exclude, :validate => :array, :default => ["@timestamp", "@metadata", "@version"]

  # Target field to write json to.
  config :target, :validate => :string

  # In case of error during evaluation, these tags will be set.
  config :tags_on_failure, :validate => :array, :default => ["_json_wrap_failure"]

  public
  def register
  end # def register

  public
  def filter(event)
    begin
      s = event.clone()
      n = LogStash::Event.new({})

      @exclude.each do |e|
        v = s.remove(e)
        n.set(e, v) if nil != v
      end

      n.set(@target, s.to_json())

      filter_matched(n)
    rescue Exception => e
      @logger.warn("an error occurred", :exception => e)
      @tags_on_failure.each { |t| event.tag(t) }
      return
    end
    yield n

    event.cancel

  rescue Exception => e
    @logger.warn("an error occurred", :exception => e)
    @tags_on_failure.each { |t| n.tag(t) }
    @tags_on_failure.each { |t| event.tag(t) }
  end # def filter
end # class LogStash::Filters::JsonWrap
