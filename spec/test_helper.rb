require 'support/factory_bot'
require_relative '../banking'
require_relative '../account'
require_relative '../transaction'
require_relative '../methods'
require 'factory_bot'
require 'yaml'

Dir['spec/support/accounts.rb'].each { |f| require f }