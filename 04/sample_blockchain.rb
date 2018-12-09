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
last_hash = ""
begin
  # Load Last Hash
  last_hash = db.restore("last_hash")
rescue StandardError
  # Create Genesys Block
  blockchain = Blockchain.new
  blockchain.create_genesis_block(wallets[:Alis])
  last_hash = db.restore("last_hash")
end

p last_hash

transactions = []
blockchain = Blockchain.new
blockchain.create_block(transactions)

# Print all blocks
last_hash = db.restore("last_hash")
current_block = db.restore(last_hash)
while current_block.prev_block_hash != ""
  p current_block.hash
  p current_block.prev_block_hash
  p "==="
  last_hash = current_block.prev_block_hash
  current_block = db.restore(last_hash)
end
