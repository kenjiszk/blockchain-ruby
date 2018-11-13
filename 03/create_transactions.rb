require './wallet.rb'
require './database.rb'
require './transactions.rb'

# Create wallet addresses by create_wallet.rb and paste here.
addresses = {
  :Alis => ENV['WALLET1'],
  :Bob => ENV['WALLET2'],
  :Carol => ENV['WALLET3']
}

# Restore walletes
wallets = {}
addresses.each do |name, address|
  wallets[name] = Wallet.new
  wallets[name].load(address)
  p "Load #{name}'s wallet : #{address}"
  wallets[name].address
end

# Restore or Create transactions
transactions = Transactions.new
begin
  transactions.load_all
rescue StandardError
  transactions.create_first_transaction(wallets)
end

new_transactions = []
new_transactions.push wallets[:Alis].pay(wallets[:Bob].address, 1)
new_transactions.push wallets[:Alis].pay(wallets[:Bob].address, 1)
new_transactions.push wallets[:Alis].pay(wallets[:Carol].address, 1)

new_transactions.each do |transaction|
  if transaction.is_valid?
    transactions.all.push transaction
    transactions.save
  end
end

wallets.each do |name, wallet|
  p "#{name}'s balance : #{transactions.balance(wallet.address)}"
end
