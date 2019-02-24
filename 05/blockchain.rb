require './block.rb'
require './database.rb'
require './proof_of_work.rb'

class Blockchain
  def initialize
  end

  def create_genesis_block(wallet)
    transaction = create_first_transaction(wallet)
    block = Block.new(Time.now.to_i, [transaction], "")
    block.set_hash
    add_block(block)
  end

  def create_first_transaction(wallet)
    input = Input.new(nil, nil, 'This is first transaction')
    output = Output.new(1000, wallet.address)
    Transaction.new(nil, [input], [output]).set_id
  end

  def create_block(transactions)
    db = Database.new
    last_hash = db.restore("last_hash")
    block = Block.new(Time.now.to_i, transactions, last_hash)
    block.set_hash
    pow = ProofOfWork.new(block)
    if pow.calculate(10000000)
      add_block(block)
    else
      p 'Failed to get nonce.'
    end
  end

  def add_block(block)
    pow = ProofOfWork.new(block)
    if pow.validate
      db = Database.new
      db.save("last_hash", block.hash)
      db.save(block.hash, block)
    else
      p 'This block is invalid in PoW.'
    end
  end
end
