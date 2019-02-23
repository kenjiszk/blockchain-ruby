require './wallet.rb'
require './blockchain.rb'
require './database.rb'

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

# Load last_hash or Create Blockchain
db = Database.new
begin
  # Load Last Hash
  last_hash = db.restore("last_hash")
rescue StandardError
  # Create Genesys Block
  p 'Blockchain not found. Create Genesys Block.'
  blockchain = Blockchain.new
  blockchain.create_genesis_block(wallets[:Alis])
  last_hash = db.restore("last_hash")
end

transactions = Transactions.new
transactions.load_all

wallets.each do |name, wallet|
  p "#{name}'s balance : #{transactions.balance(wallet.address)}"
end

new_transactions = []
new_transactions.push wallets[:Alis].pay(wallets[:Bob].address, 100)
new_transactions.push wallets[:Bob].pay(wallets[:Carol].address, 100)

new_transactions.each do |transaction|
  if transaction.is_valid?
    transactions.add_to_mem_pool transaction
  else
    transactions.delete_mem_pool
    break
  end
end

if transactions.mem_pool.count > 0
  p 'create new block with valid new transactions'
  blockchain = Blockchain.new
  blockchain.create_block(transactions.mem_pool)
  transactions.delete_mem_pool
end

wallets.each do |name, wallet|
  p "#{name}'s balance : #{transactions.balance(wallet.address)}"
end
