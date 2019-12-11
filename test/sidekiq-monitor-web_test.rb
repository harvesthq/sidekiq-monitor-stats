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
    assert_equal([], body['jobs'])
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
      ],
      job_metrics: [
        'process' => 'foo:1234',
        'thread'  => '1001',
        'jid'     => '1234abc',
        'queue'   => 'default',
        'job'     => 'WebWorker',
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

    assert_equal 1, body['jobs'].size
    job = body['jobs'].first
    assert_equal 'foo:1234',  job['process']
    assert_equal '1001',      job['thread']
    assert_equal '1234abc',   job['jid']
    assert_equal 'default',   job['queue']
    assert_equal 'WebWorker', job['job']
  end

  private

  def app
    Sidekiq::Web
  end
end
