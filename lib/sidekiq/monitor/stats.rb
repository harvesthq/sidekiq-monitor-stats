require 'sidekiq/api'
require 'sidekiq/web'
require 'sidekiq/monitor/web'

module Sidekiq
  module Monitor
    class Stats
      def queue_metrics
        Sidekiq::Queue.all.each_with_object({}) do |queue, hash|
          hash[queue.name] = {
            backlog: queue.size,
            latency: queue.latency.to_i
          }
        end
      end

      def process_metrics
        Sidekiq::ProcessSet.new.map do |process|
          {
            hostname:    process['hostname'],
            pid:         process['pid'],
            tag:         process['tag'],
            started_at:  Time.at(process['started_at']),
            queues:      process['queues'],
            labels:      process['labels'],
            concurrency: process['concurrency'],
            busy:        process['busy']
          }
        end
      end

      def job_metrics
        jobs = []

        Sidekiq::Workers.new.each do |process, thread, msg|
          job = Sidekiq::Job.new(msg['payload'])
          jobs << {
            process: process,
            thread: thread,
            jid: job.jid,
            queue: msg['queue'],
            job: job.display_class,
            run_at: Time.at(msg['run_at'])
          }
        end

        jobs
      end
    end
  end
end

Sidekiq::Web.register(Sidekiq::Monitor::Web)
