require 'base58'
require 'digest'
require 'ecdsa'
require 'securerandom'
require './database.rb'

class Wallet
  attr_accessor :private_key, :public_key

  def initialize
    @private_key = nil
    @public_key = nil
  end

  def create_key
    # Create private_key of ECDSA and public_key
    group = ECDSA::Group::Secp256k1
    @private_key = 1 + SecureRandom.random_number(group.order - 1)
    @public_key = group.generator.multiply_by_scalar(private_key)
  end

  def address
    compressed_public_key = prefix + @public_key.x.to_s(16)
    hashed_public_key = double_hash(compressed_public_key)
    hashed_public_key_with_network_byte = "00" + hashed_public_key
    row_address = hashed_public_key_with_network_byte + checksum(hashed_public_key_with_network_byte)
    Base58.binary_to_base58([row_address].pack("H*"), :bitcoin)
  end

  def prefix
    if @public_key.y.to_s[-1] % 2 == 0
      "02"
    else
      "03"
    end
  end

  def double_hash(key)
    sha256 = Digest::SHA256.hexdigest [key].pack("H*")
    Digest::RMD160.hexdigest [sha256].pack("H*")
  end

  def checksum(key)
    sha256 = Digest::SHA256.hexdigest [key].pack("H*")
    double_sha256 = Digest::SHA256.hexdigest [sha256].pack("H*")
    double_sha256[0..7]
  end

  def save
    key = "wallet" + self.address
    db = Database.new
    db.save(key, self)
  end

  def load(address)
    key = "wallet" + address
    db = Database.new
    saved_wallet = db.restore(key)
    @private_key = saved_wallet.private_key
    @public_key = saved_wallet.public_key
  end

  def pay(to, amount)
    transactions = Transactions.new
    transactions.load_all
    use_utxo, use_amount = transactions.collect_enough_utxo(self.address, amount)
    inputs =[]
    use_utxo.each do |transaction_id, output_indexes|
      output_indexes.each do |output_index|
        inputs.push Input.new(transaction_id, output_index, nil)
      end
    end
    outputs = []
    outputs.push Output.new(amount, to)
    outputs.push Output.new(use_amount - amount, address)
    Transaction.new(nil, inputs, outputs).set_id
  end
end
