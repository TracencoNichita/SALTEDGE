# frozen_string_literal: true

require_relative 'account'
require_relative 'transaction'
require 'pry'

# class Neyvabank
class Neyvabank
  attr_accessor :browser, :account

  def connect
    @browser = Watir::Browser.new :chrome
    @browser.goto('https://bank-on-line.ru//?registered=true')
    @browser.a(text: 'Демо-вход').click
    @browser.goto('https://bank-on-line.ru//?registered=true#Contracts')
  end

  def fetch_accounts
    sleep(4)
    browser.trs(class: %w[cp-item]).each do |row|
      row.click
      sleep(4)
      html = Nokogiri::HTML.fragment(browser.div(id: 'tblWrap').html)
      account = parse_account(html)
      account.parse_transactions(account.fetch_transactions(browser))
      account.to_json
      # save_accounts_to_file(html)
      browser.goto('https://bank-on-line.ru//?registered=true#Contracts')
    end
  end

  def parse_account(html)
    name = html.css('div#divMain.cp-page.row').css('div.small-3.column.caption-table.contract')
               .css('div.caption-hint').text
    currency = currency_res(html.css('div#divMain.cp-page.row').css('tr')[2].at_css('td.tdFieldVal').text)
    balance = html.css('div#divMain.cp-page.row').css('tr')[5].css('td.tdFieldVal').text
    nature = html.css('div.small-3.column.caption-table.contract').css('div.caption-text').text
    Account.new(name, currency, balance.delete(' ').to_f, nature)
  end

  def currency_res(currency)
    case currency
    when 'Российский рубль'
      'RUR'
    when 'Евро'
      'EUR'
    when 'Доллар США'
      'USD'
    end
  end

  # def save_accounts_to_file(data)
  #  filename = 'accounts.html'
  #  File.write(filename, data.to_html, mode: 'w')
  # end

  # def save_transactions_to_file(data)
  # filename = 'transactions.html'
  # File.write(filename, data.to_html, mode: 'w')
  # end
end
