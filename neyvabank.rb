# frozen_string_literal: true

require 'watir'
require 'nokogiri'
require 'open-uri'
require 'rubocop'

# class Account
class Account
  attr_accessor :name, :currency, :balance, :nature, :transactions

  def initialize(name, currency, balance, nature)
    @name = name
    @currency = currency
    @balance = balance
    @nature = nature
    @transactions = []
  end

  def add_transaction(date, description, amount, currency, account_name)
    transaction = Transaction.new(date, description, amount, currency, account_name)
    hash = transaction.to_hash
    @transactions.push(hash)
  end

  def parse_json
    accounts = File.read('accounts.json')
    JSON.parse(accounts)
  end

  def to_json(*_args)
    hash = {  'name' => name,
              'currency' => currency,
              'balance' => balance,
              'nature' => nature,
              'transactions' => transactions }
    json = parse_json
    json['accounts'] << hash
    File.open('accounts.json', 'w') do |f|
      f.write(JSON.pretty_generate(json))
    end
  end
end

# class Transaction
class Transaction
  attr_accessor :date, :description, :amount, :currency, :account_name

  def initialize(date = nil, description = nil, amount = nil, currency = nil, account_name = nil)
    @date = date
    @description = description
    @amount = amount
    @currency = currency
    @account_name = account_name
  end

  def to_hash
    { 'date' => date,
      'description' => description,
      'amount' => amount * -1,
      'currency' => currency,
      'account_name' => account_name }
  end
end

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
    browser.table(class: %w[cp-page-list tblBlock cp-with-context-menu]).each do |row|
      next if row.text == browser.table(class: %w[cp-page-list tblBlock cp-with-context-menu]).rows[0].text
      next if row.text == browser.table(class: %w[cp-page-list tblBlock cp-with-context-menu]).rows[1].text

      row.click
      sleep(4)

      html = Nokogiri::HTML.fragment(browser.div(id: 'tblWrap').html)
      # save_accounts_to_file(html)
      account = parse_accounts(html)
      fetch_transactions(account)
      browser.goto('https://bank-on-line.ru//?registered=true#Contracts')
    end
  end

  def fetch_transactions(account)
    browser.div(text: 'Список операций').click
    add_date('Сентябрь')
    sleep(3)
    html = Nokogiri::HTML.fragment(browser.div(id: 'mainTD').html)
    # save_transactions_to_file(html)
    parse = parse_transactions(html, account)
    parse.to_json
  end

  def parse_accounts(html)
    name = html.css('div#divMain.cp-page.row').css('div.small-3.column.caption-table.contract')
               .css('div.caption-hint').text
    currency = currency_res(html.css('div#divMain.cp-page.row').css('tr')[2].css('td.tdFieldVal').text)
    balance = html.css('div#divMain.cp-page.row').css('tr')[5].css('td.tdFieldVal').text
    nature = html.css('div.small-3.column.caption-table.contract').css('div.caption-text').text
    Account.new(name, currency, balance.delete(' ').to_f, nature)
  end

  def parse_transactions(html, account)
    html.css('tr.cp-item.cp-transaction').each do |item|
      date = item.css('td.td-action.with-hover.trans-time.text-center.cp-no-export')[0]
                 .css('div.cp-time')[0].at_xpath('text()')
      description = item.css('td.TranDescription.td-action.with-hover.cp-export')[0].at_xpath('text()')
      currency = item.css('td.cp-export-only.cp-export')[2].text
      amount = item.css('td.tranListMoney.nowrap.td-action.with-hover.cp-no-export')[0].text
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
      currency = 'RUR'
    when 'Евро'
      currency = 'EUR'
    when 'Доллар США'
      currency = 'USD'
    end
    currency
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
