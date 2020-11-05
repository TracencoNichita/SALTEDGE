require 'watir'
require 'nokogiri'
require 'open-uri'
require_relative 'account'
require_relative 'banking'
require_relative 'methods'

browser = Watir::Browser.new :chrome

account1 = Banking.new('https://demo.bank-on-line.ru/?registered=demo#Contracts/40817810200000055320', browser)
account1.create_browser

account2 = Banking.new('https://demo.bank-on-line.ru/?registered=demo#Contracts/40817840400000055321', browser)
account2.create_browser

account3 = Banking.new('https://demo.bank-on-line.ru/?registered=demo#Contracts/40817978300000055322', browser)
account3.create_browser
puts "Data is saved in accounts.json"