require_relative "transaction"
require "json"
require "rubocop"

class Account
  attr_accessor :name, :currency, :balance, :nature, :transactions
  def initialize(name=nil, currency=nil, balance=nil, nature=nil)
    @name = name
    @currency = currency
    @balance = balance
    @nature = nature
    @transactions = []
  end

  def add_transaction(date, description, amount, currency, account_name)
    transaction = Transaction.new(date, description, amount, currency, account_name)
    hash = transaction.transaction_to_json
    @transactions.push(hash)
  end

  def parse_json
    accounts = File.read('accounts.json')
    JSON.parse(accounts)
  end

  def to_json
    file='accounts.json'
    hash = {"name" => name, "currency" => currency, "balance" => balance, "nature" => nature, "transactions" => transactions }
    json = parse_json
    json["accounts"] << hash
    File.open(file,"w") do |f|
      f.write(JSON.pretty_generate(json))
    end
  end
end