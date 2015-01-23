require 'sidekiq/monitor/stats'

module Sidekiq
  module Monitor
    module Web
      def self.registered(app)
        app.get "/monitor-stats" do
          monitor_stats = Monitor::Stats.new

          content_type :json
          Sidekiq.dump_json(
            queues:    monitor_stats.queue_metrics,
            processes: monitor_stats.process_metrics
          )
        end
      end
    end
  end
end
