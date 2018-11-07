require './wallet.rb'

# Prepare 3 wallets
(1..3).each do ||
  wallet = Wallet.new
  wallet.create_key
  p wallet.address
  wallet.save
end
