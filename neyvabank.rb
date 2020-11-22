# frozen_string_literal: true

require_relative 'account'
require_relative 'transaction'
require 'pry'

# class Neyvabank
class Neyvabank
  attr_accessor :browser, :account, :accounts, :accounts_links

  def initialize
    @accounts = []
    @accounts_links = []
  end

  def connect
    @browser = Watir::Browser.new :chrome
    @browser.goto('https://bank-on-line.ru//?registered=true')
    @browser.a(text: 'Демо-вход').click
    @browser.goto('https://bank-on-line.ru//?registered=true#Contracts')
  end

  def fetch_accounts
    sleep(5)
    @browser.trs(class: %w[cp-item]).each do |row|
      row.click
      sleep(5)
      html = Nokogiri::HTML.fragment(browser.div(id: 'tblWrap').html)

      # save parsed account and accounts link in array
      @accounts << parse_account(html)
      @accounts_links << row
      browser.goto('https://bank-on-line.ru//?registered=true#Contracts')
    end
    accounts
  end

  def fetch_transactions
    # an iterator for account links
    i = 0
    @accounts.each do |account|
      # navigate to transactions
      @accounts_links[i].click
      @browser.div(text: 'Список операций').click

      # set date for 2 month
      add_date('Сентябрь')

      # parsing transactions for the current account
      sleep(3)
      html = Nokogiri::HTML.fragment(@browser.div(id: 'mainTD').html)
      parse = parse_transactions(html, account)
      parse.to_json
      i += 1
      browser.goto('https://bank-on-line.ru//?registered=true#Contracts')
    end
  end

  def parse_account(html)
    name = html.css('div.small-3.column.caption-table.contract').css('div.caption-hint').text
    currency = currency_res(html.css('div#divMain').css('tr')[2].css('td.tdFieldVal').text)
    balance = html.css('div#divMain').css('tr')[5].css('td.tdFieldVal').text
    nature = html.css('div.small-3.column.caption-table.contract').css('div.caption-text').text
    Account.new(name, currency, balance.delete(' ').to_f, nature)
  end

  def parse_transactions(html, account)
    html.css('tr.cp-item').each do |item|
      date = item.css('td.td-action').css('div.cp-time').children.first.text
      description = item.css('td.TranDescription').children.first.text
      currency = item.css('td.cp-export-only')[2].text
      amount = item.css('td.tranListMoney')[0].text
      account_name = account.name
      account.add_transaction(date.to_s.strip, description.to_s.strip, amount.delete(' ').to_f, currency, account_name)
    end
    account
  end

  def add_date(month)
    browser.input(name: 'DateFrom').click
    browser.select(class: 'ui-datepicker-month').select(month)
    browser.table(class: 'ui-datepicker-calendar').a(class: 'ui-state-default').click
    browser.span(id: 'getTranz').click
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
