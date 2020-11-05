require "spec_helper"

describe 'Banking' do
  describe '#create' do
    it "parcing Watir" do
      browser = Watir::Browser.new :chrome
      browser.goto("https://demo.bank-on-line.ru")
      page = Nokogiri::HTML.parse(browser.html)
      expect(page.css('title').text).to eq("Банк-он-Лайн")
    end

    browser = Watir::Browser.new :chrome
    browser.goto("https://demo.bank-on-line.ru/?registered=demo#Contracts/40817810200000055320")
    sleep(10)
    page = Nokogiri::HTML.parse(browser.html)

    it 'creates account' do
      account = create_account(page)
      expect(account.name).to eq('40817810200000055320')
    end

    it 'creates transaction' do
      account = create_account(page)
      account = create_transaction(page, account)
      expect(account[0].css('td.cp-export-only.cp-export')[2].text).to eq("RUR")
    end
  end
end
