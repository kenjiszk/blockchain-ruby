require './wallet.rb'
require './database.rb'
require './transaction.rb'
require './input.rb'
require './output.rb'
require './transactions.rb'

addresses = {
  :Alis => ENV['WALLET1'],
  :Bob => ENV['WALLET2'],
  :Carol => ENV['WALLET3']
}

wallets = {}
addresses.each do |name, address|
  wallets[name] = Wallet.new
  wallets[name].load(address)
  p "Load #{name}'s wallet : #{address}"
  wallets[name].address
end

transactions = Transactions.new
begin
  transactions.load_all
rescue StandardError
  p 'Load is failed. Create new transaction'
  transactions.create_first_transaction(wallets)
end

p 'List of transaction ids'
transactions.all.each do |transaction|
  p transaction.id
end

wallets.each do |name, wallet|
  p "#{name}'s balance : #{transactions.balance(wallet.address)}"
end

p 'Send 10 coin from Alis to Bob.'
new_transaction = wallets[:Alis].pay(wallets[:Bob].address, 10)
transactions.all.push new_transaction
transactions.save

wallets.each do |name, wallet|
  p "#{name}'s balance : #{transactions.balance(wallet.address)}"
end
