require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "minitest/reporters"
Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new, ENV, Minitest.backtrace_filter)

require 'minitest/rails/capybara'
require 'capybara/poltergeist'
Capybara.configure do |c|
  c.javascript_driver = :poltergeist
  c.default_driver = :poltergeist
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
