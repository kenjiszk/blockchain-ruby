require './wallet.rb'
require './database.rb'

# Create wallet addresses by create_wallet.rb and paste here.
addresses = {
  "Alis" => ENV['WALLET1'],
  "Bob" => ENV['WALLET2'],
  "Carol" => ENV['WALLET3']
}

# Restore walletes
wallets = {}
addresses.each do |name, address|
  wallets[name] = Wallet.new.load(address)
  p "Load #{name}'s wallet : #{address}"
  wallets[name].address
end

# Restore or Create transactions
transactions = []
db = Database.new
key = "transactions"

begin
  # Restore transactions if exist
  p "Restore Transactions from Database"
  transactions = db.restore(key)
rescue
  # Create coinbase transaction
  # Alis got 1000 coins
  p "Create First Transaction"
  input = Input.new(nil, nil, 'This is first transaction')
  output = Output.new(1000, wallets['Alis'].address)
  transactions.push Transaction.new(nil, [input], [output]).set_id
  db.save(key, transactions)
end

transactions.push wallets['Alis'].pay(wallets['Bob'].address, 1, transactions)
transactions.push wallets['Alis'].pay(wallets['Bob'].address, 1, transactions)
transactions.push wallets['Alis'].pay(wallets['Carol'].address, 1, transactions)
db.save(key, transactions)

wallets.each do |name, wallet|
  p "#{name}'s balance : #{wallet.balance(transactions)}"
end
