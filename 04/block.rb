require 'digest'

class Block
  attr_accessor :timestamp, :transactions, :prev_block_hash, :hash, :nonce
  def initialize(timestamp, transactions, prev_block_hash)
    @timestamp = timestamp
    @transactions = transactions
    @prev_block_hash = prev_block_hash
    @hash = nil
  end

  def set_hash
    @hash = Digest::SHA256.hexdigest(Time.now.to_s + @prev_block_hash)
  end
end
