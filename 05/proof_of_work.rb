class ProofOfWork
  def initialize(block)
    @target_block = block
    @target_bits = 20
    @target = set_target
  end

  def set_target
    (1 << (256 - @target_bits)).to_s(16)
  end

  def calculate(nonce_limit)
    (1..nonce_limit).each{|nonce|
      hash = get_hash(nonce.to_s)
      if (hash.hex < @target.hex)
        @target_block.nonce = nonce
        @target_block.hash = hash
        return true
      end
    }
    false
  end

  def validate
    hash = get_hash(@target_block.nonce.to_s)
    hash.hex < @target.hex
  end

  def get_hash(prev_block_hash, data, timestamp, nonce)
    headers = prev_block_hash + data + timestamp + nonce
    Digest::SHA256.hexdigest headers
  end

  def get_hash(nonce)
    headers = @target_block.prev_block_hash.to_s + @target_block.transactions_hash.to_s + @target_block.timestamp.to_s + nonce.to_s
    Digest::SHA256.hexdigest headers
  end
end
