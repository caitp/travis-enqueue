require 'travis'
require 'travis/enqueue'

$stdout.sync = true

Travis.config.update_periodically
Travis.config.queue.interval = 15
Travis::Amqp.config = Travis.config.amqp

Travis::Features.start
Travis::Exceptions::Reporter.start
Travis::Database.connect
Travis::Notification.setup

def active?
  Travis::Features.feature_active?(:travis_enqueue)
end

def run
  Travis.run_service(:enqueue_jobs)
end

def format(reports)
  Array(reports).map do |owner, report|
    "  #{owner}: #{report.map { |key, value| "#{key}: #{value}" }.join(', ')}"
  end
end

interval = Travis.config.queue.interval
thread = run_periodically(interval) { run if active? }
thread.join

