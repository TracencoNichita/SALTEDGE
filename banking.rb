require 'watir'
require 'nokogiri'
require 'open-uri'
require_relative 'account'

class Banking
  attr_accessor :page, :browser
  def initialize(page, browser)
    @page = page
    @browser = browser
  end
  def create_browser
    browser.goto(page)
    sleep(10)
    page = Nokogiri::HTML.parse(browser.html)
    account = create_account(page)
    create_transaction(page, account)
    account.to_json
  end
end