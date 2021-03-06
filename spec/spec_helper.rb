begin
  require 'simplecov'
  require 'coveralls' if ENV['CI']
rescue LoadError
  # ignore
end

begin
  require 'byebug'
rescue LoadError
  # ignore
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'anystyle'

AnyStyle::Dictionary.defaults[:adapter] = :memory

module Fixtures
  PATH = File.expand_path('../fixtures', __FILE__).untaint

	Dir[File.join(PATH, '*.rb')].each do |fixture|
		require fixture
	end

  def fixture_path(path)
    File.join(PATH, path)
  end
end

RSpec.configure do |config|
  config.include Fixtures
end
