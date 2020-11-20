# frozen_string_literal: true

require_relative 'transaction'

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

  def fetch_transactions(browser)
    browser.div(text: 'Список операций').click
    add_date('Сентябрь', browser)
    sleep(3)
    Nokogiri::HTML.fragment(browser.div(id: 'mainTD').html)
  end

  def parse_transactions(html)
    html.css('tr.cp-item.cp-transaction').each do |item|
      date = item.css('td.td-action.with-hover.trans-time.text-center.cp-no-export')
                 .css('div.cp-time').children.first.text
      description = item.css('td.TranDescription.td-action.with-hover.cp-export').children.first.text
      currency = item.css('td.cp-export-only.cp-export')[2].text
      amount = item.css('td.tranListMoney.nowrap.td-action.with-hover.cp-no-export')[0].text
      account_name = name
      add_transaction(date.to_s.strip, description.to_s.strip, amount.delete(' ').to_f, currency, account_name)
    end
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

  def add_date(month, browser)
    browser.input(name: 'DateFrom').click
    browser.select(class: 'ui-datepicker-month').select(month)
    browser.table(class: 'ui-datepicker-calendar').a(class: 'ui-state-default').click
    browser.span(id: 'getTranz').click
  end
end
