require 'simplecov'
SimpleCov.start do
  add_filter '/_test/' # Exclude tests
  track_files '/lib/**/*.rb'
end

# Init RSpec
require 'rspec'

def silence_output
  @original_stdout = $stdout
  $stdout = StringIO.new
end

def enable_output
  $stdout = @original_stdout if @original_stdout
end

def capture_stdout
  silence_output
  yield
  output = $stdout.string
  enable_output
  output
  silence_output
end

RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:enable_output]
      enable_output
      example.run
      silence_output
    else
      silence_output
      example.run
    end
  end
end