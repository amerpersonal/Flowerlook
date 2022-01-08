# This file is used by Rack-based servers to start the application.

require_relative "config/environment"


# require 'coverband'
# require File.dirname(__FILE__) + '/config/environment'


run Rails.application
Rails.application.load_server


# use Coverband::BackgroundMiddleware
# run ActionController::Dispatcher.new
