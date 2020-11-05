require 'factory_bot'
FactoryBot.define do
  factory :account do
    name        {'7489218489124898'}
    currency    {'Молдавский Лей'}
    balance     {'21978'}
    nature      {'Master Card'}
  end

  factory :transaction do
    date         {'04.11.2020:12:25:52'}
    description  {'Оплата услуг Молдчел'}
    amount       {'MDL'}
    currency     {'130.00'}
    account_name {'891562******4576'}
  end
end