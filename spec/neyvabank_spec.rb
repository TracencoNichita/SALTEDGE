# frozen_string_literal: true

require 'rspec'
require 'nokogiri'
require 'open-uri'
require_relative '../neyvabank'

describe 'Neyvabanc' do
  it 'show an example account' do
    bank = Neyvabank.new
    html = Nokogiri::HTML(File.read('accounts.html'))
    accounts = bank.parse_accounts(html)
    data = accounts.instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.delete('@')] = accounts.instance_variable_get(var)
    end
    expect(data).to eq({
                         'name' => '40817978300000055322',
                         'currency' => 'EUR',
                         'balance' => 100_000.0,
                         'nature' => 'Счёт',
                         'transactions' => []
                       })
  end

  it 'check number of transactions and show an example transaction' do
    bank = Neyvabank.new
    html = Nokogiri::HTML(File.read('transactions.html'))
    account = Account.new('40817810200000055320', 'RUR', 100_000.0, 'Счёт')
    account = bank.parse_transactions(html, account)
    expect(account.transactions.count).to eq(5)
    expect(account.transactions.first.to_h).to eq({
                                                    'date' => '15.11.2020',
                                                    'description' => 'Оплата услуг МегаФон Урал, Номер телефона: 79111111111, 15.11.2020 11:59:59, Сумма 50.00 RUB, Банк-он-Лайн',
                                                    'amount' => -50.0,
                                                    'currency' => 'RUR',
                                                    'account_name' => '40817810200000055320'
                                                  })
  end
end
