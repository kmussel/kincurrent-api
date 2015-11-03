#!/bin/bash

set -m

gem install bundler

bundle install

torquebox deploy

bundle exec jruby lib/tasks/orientdb_task.rb create_schema

torquebox start -b 0.0.0.0 -p 8000
