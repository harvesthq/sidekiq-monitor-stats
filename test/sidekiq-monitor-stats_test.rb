require 'test_helper'

class Sidekiq::Monitor::StatsTest < Minitest::Test
  def setup
    Sidekiq.redis { |conn| conn.flushdb }
  end

  def test_returns_empty_data
    assert_equal({}, stats.queue_metrics)
    assert_equal([], stats.process_metrics)
  end

  def test_with_some_data
    Sidekiq.redis do |conn|
      @started_at = Time.now

      conn.sadd("queues", "default")
      conn.lpush("queue:default", Sidekiq.dump_json('enqueued_at' => @started_at.to_f))

      conn.sadd('processes', 'foo:1234')

      process_stats = {
        hostname:   'foo',
        pid:        1234,
        tag:        'default',
        started_at: Time.now.to_f,
        queues:     ['default'],
        labels:     ['reliable'],
        concurrency: 25
      }

      conn.hmset('foo:1234', 'info', Sidekiq.dump_json(process_stats), 'at', @started_at.to_f, 'busy', 4)
    end

    assert_equal({ backlog: 1, latency: 0 }, stats.queue_metrics['default'])

    process = stats.process_metrics.first
    assert_equal "foo",        process[:hostname]
    assert_equal 1234,         process[:pid]
    assert_equal 'default',    process[:tag]
    assert_equal ['default'],  process[:queues]
    assert_equal ['reliable'], process[:labels]
    assert_equal 25,           process[:concurrency]
    assert_equal 4,            process[:busy]
    assert_in_delta @started_at, process[:started_at], 0.01
  end

  private

  def stats
    Sidekiq::Monitor::Stats.new
  end
end
