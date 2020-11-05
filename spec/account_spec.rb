require "spec_helper"

describe 'Account' do
  it 'adds transaction' do
    account = build(:account)
    account.transactions = build(:transaction).transaction_to_json
    expect(account.transactions).to have_key('date')
  end
  
  describe '#to_json' do
    it 'parse_json' do
        accounts = File.read 'test.json'
        expect(JSON.parse(accounts)).to have_key('accounts')
    end

    it 'adds account to json file' do
      account = build(:account)
      account.transactions = build(:transaction).transaction_to_json
      hash = {"name" => "7489218489124898", "currency" => "Молдавский Лей", "balance" => "21978", "nature" => "Master Card", "transactions" => account.transactions}
      file = 'test.json'

      accounts = File.read(file)
      json = JSON.parse(accounts)
      json["accounts"] << hash
      File.open(file,"w") do |f|
        f.write(JSON.pretty_generate(json))
      end

      accounts = File.read(file)
      json = JSON.parse(accounts)
      expect(json['accounts'][0]).to have_key('name')
    end
  end
end
