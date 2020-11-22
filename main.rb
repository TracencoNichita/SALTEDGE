# frozen_string_literal: true

require 'watir'
require 'nokogiri'
require 'open-uri'
require 'rubocop'
require_relative 'neyvabank'

bank = Neyvabank.new
bank.connect
bank.fetch_accounts
bank.fetch_transactions
