require './wallet.rb'

# Prepare 3 wallets
(1..3).each do |index|
  wallet = Wallet.new
  wallet.create_key
  puts "export WALLET#{index}=#{wallet.address}"
  wallet.save
end
