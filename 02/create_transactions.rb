require './wallet.rb'

# Create first conbase transaction
wallet0 = Wallet.new
wallet0.create_key
input = Input.new(nil, nil, 'This is first transaction')
output = Output.new(10000, wallet0.address)
transaction0 = Transaction.new(nil, [input], [output])
transaction0.set_id

# Send 1 coin to other wallet
wallet1 = Wallet.new
wallet1.create_key

input = Input.new(transaction0.id, 0, 'Signature')
output = Output.new(1, wallet1.address)
transaction1 = Transaction.new(nil, [input], [output])
transaction1.set_id

[transaction0, transaction1].each do |transaction|
  p transaction
end

def sign(transaction)
  'Signature'
end
