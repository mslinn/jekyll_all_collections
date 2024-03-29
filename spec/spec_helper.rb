require 'jekyll'
require 'date'

require_relative '../lib/jekyll_all_collections'

Jekyll.logger.log_level = :info

RSpec.configure do |config|
  # config.order = 'random'
  config.filter_run_when_matching focus: true

  # See https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures
  config.example_status_persistence_file_path = 'spec/status_persistence.txt'
end
