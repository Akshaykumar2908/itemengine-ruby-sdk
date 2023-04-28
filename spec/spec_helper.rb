require "bundler/setup"
require "itemengine/sdk"
require "itemengine/sdk/exceptions"
require "itemengine/sdk/request"
require "itemengine/sdk/request/init"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
