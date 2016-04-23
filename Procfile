web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec sidekiq -q default,2 -q task -q image
clock: bundle exec clockwork lib/clock.rb

