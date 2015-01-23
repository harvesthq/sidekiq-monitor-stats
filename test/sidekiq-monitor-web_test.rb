require 'test_helper'
require 'rack/test'

class Sidekiq::Monitor::WebTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    Sidekiq.redis { |conn| conn.flushdb }
  end

  def test_monitor_stats_empty
    get '/monitor-stats'

    assert_equal 200, last_response.status

    body = Sidekiq.load_json(last_response.body)
    assert_equal({}, body['queues'])
    assert_equal([], body['processes'])
  end

  def test_monitor_stats_with_some_data
    Sidekiq::Monitor::Stats.any_instance.expects(
      queue_metrics: { 'default' => { 'backlog' => 5, 'latency' => 10 } },
      process_metrics: [
        'hostname'   => 'kip.local',
        'pid'        => '12345',
        'queues'     => ['default', 'high'],
        'concurrency'=> 25,
        'busy'       => 4
      ]
    )
    get '/monitor-stats'

    assert_equal 200, last_response.status

    body = Sidekiq.load_json(last_response.body)
    assert_equal 5,  body['queues']['default']['backlog']
    assert_equal 10, body['queues']['default']['latency']

    assert_equal 1, body['processes'].size
    process = body['processes'].first
    assert_equal 'kip.local',        process['hostname']
    assert_equal '12345',            process['pid']
    assert_equal ['default','high'], process['queues']
    assert_equal 25,                 process['concurrency']
    assert_equal 4,                  process['busy']
  end

  private

  def app
    Sidekiq::Web
  end
end
