# Sidekiq Monitor Stats

Add an endpoint to your running application that is running Sidekiq that
returns useful data in JSON format.

The intention is to provide useful data for something like a sensu check
to monitor if Sidekiq is working correctly.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-monitor-stats'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-monitor-stats

## Usage

This will automatically add another endpoint wherever you have mounted
your sidekiq web. Just visit `<mounted-path>/monitor-stats` to see some stats.

This is an example of the output you'll get:

```json
{
  "queues":{
    "default":{
      "backlog":15,
      "latency":2
    },
    "high":{
      "backlog":0,
      "latency":0
    },
    "low":{
      "backlog":533,
      "latency":54
    }
  },
  "processes":[
    {
      "hostname":"kip1.example.com",
      "pid":23324,
      "queues":[
        "high"
      ],
      "concurrency":5,
      "busy":2
    },
    {
      "hostname":"kip2.example.com",
      "pid":23390,
      "queues":[
        "default",
        "low"
      ],
      "concurrency":5,
      "busy":5
    }
  ]
}
```

It will return a `queues` hash and a `processes` array.

The `queues` hash contains the existing queues with their names, the backlog
and the latency. The backlog is the amount of jobs waiting to be processed,
and the latency is the maximum time (in seconds) a job has been waiting in
the queue.

The `processes` array returns useful information about each sidekiq process.
The `concurrency`, in Sidekiq terms, is the maximum jobs a process can go
through in parallel. The `busy` is how many of those are in use.

If you plan on using this for your monitoring, the `latency` is a much
better metric than the `backlog`, and you can use the total `concurrency` and
total `busy` to know how much of your available workforce is in use.
