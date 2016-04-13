# Sidekiq Monitor Stats

[![Gem Version](https://badge.fury.io/rb/sidekiq-monitor-stats.svg)](http://badge.fury.io/rb/sidekiq-monitor-stats)
[![Build Status](https://travis-ci.org/harvesthq/sidekiq-monitor-stats.svg)](https://travis-ci.org/harvesthq/sidekiq-monitor-stats)
[![Code Climate](https://codeclimate.com/github/harvesthq/sidekiq-monitor-stats/badges/gpa.svg)](https://codeclimate.com/github/harvesthq/sidekiq-monitor-stats)

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
      "tag": "foo",
      "started_at": "2015-04-10T13:04:22+00:00",
      "queues":[
        "high"
      ],
      "labels": [
        "reliable"
      ],
      "concurrency":5,
      "busy":2
    },
    {
      "hostname":"kip2.example.com",
      "pid":23390,
      "tag": "foo",
      "started_at": "2015-04-10T13:04:22+00:00",
      "queues":[
        "default",
        "low"
      ],
      "labels": [
        "reliable"
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

## Sensu Scripts

[These sensu scripts](https://github.com/sensu-plugins/sensu-plugins-sidekiq) are designed to work with this gem to provide sane monitoring. The check script will raise warnings if the latency gets above certain threshold, and the metrics script will record useful metrics to help you figure out how your sidekiq is doing and if you need more workers.

If you're using some other monitoring tool they are good inspiration to know how this gem was intended to be used.
