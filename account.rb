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

  def parse_json
    accounts = File.read('accounts.json')
    JSON.parse(accounts)
  end

  def to_hash
    { 'name' => name,
      'currency' => currency,
      'balance' => balance,
      'nature' => nature,
      'transactions' => transactions }
  end

  def to_json(*_args)
    hash = to_hash
    json = parse_json
    json['accounts'] << hash
    File.open('accounts.json', 'w') do |f|
      f.write(JSON.pretty_generate(json))
    end
  end
end
