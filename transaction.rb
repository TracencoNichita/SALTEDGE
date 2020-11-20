# frozen_string_literal: true

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
