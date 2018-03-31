ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'sidekiq/testing'
require 'vcr'

# include all support helpers
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

VCR.configure do |config|
  config.cassette_library_dir = "test/vcrs"
  config.hook_into :webmock
end

# quiet logger during tests
BridgePay.logger.level = Logger::ERROR

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include AuthHelper
  include JsonHelper
  include SeedDbHelper

  def after_teardown
    Sidekiq::Worker.clear_all
    super
  end
end

class ActionDispatch::IntegrationTest
  include AuthHelper
  include JsonHelper
  include SeedDbHelper

  def after_teardown
    Sidekiq::Worker.clear_all
    super
  end
end
