#!/usr/bin/env puma

environment ENV['RAILS_ENV'] || 'production'

daemonize false

pidfile "/var/www/core/shared/tmp/pids/puma.pid"
stdout_redirect "/var/www/core/shared/tmp/log/stdout", "/var/www/core/shared/tmp/log/stderr"

threads 0, 16

bind "unix:///var/www/core/shared/tmp/sockets/puma.sock"
