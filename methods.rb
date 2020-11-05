#It's the method which create an object Account with special values
def create_account(page)
  name = page.css('div#divMain.cp-page.row').css('div.small-3.column.caption-table.contract').css('div.caption-hint').text
  currency = page.css('div#divMain.cp-page.row').css('tr')[2].css('td.tdFieldVal').text
  balance = page.css('div#divMain.cp-page.row').css('tr')[5].css('td.tdFieldVal').text
  nature = ''
  page.css('tr.blockBody.Active').each do |item|
  nature += item.css('td')[4].text
  end
  account = Account.new(name, currency, balance, nature)
end
  
def create_transaction(page, account)
  page.css('tr.cp-item.cp-transaction').each do |item|
  date = item.css('td.td-action.with-hover.trans-time.text-center.cp-no-export')[0].css('div.cp-time')[0].text
  description = item.css('td.TranDescription.td-action.with-hover.cp-export')[0].xpath('text()')
  amount = item.css('td.cp-export-only.cp-export')[2].text
  currency = item.css('td.tranListMoney.nowrap.td-action.with-hover.cp-no-export')[0].text
  account_name = item.css('td.cp-export.cp-export-only')[7].text
  account.add_transaction(date, description, amount, currency, account_name)
  end
end