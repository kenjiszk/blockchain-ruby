require 'securerandom'
require './transactions.rb'

class Transaction
  attr_accessor :id, :inputs, :outputs

  def initialize(id, inputs, outputs)
    @id = id
    @inputs = inputs
    @outputs = outputs
  end

  def set_id
    @id = get_hash
    self
  end

  def get_hash
    transaction_info = self.inputs.map do |input|
      input.transaction_id.to_s + input.related_output.to_s
    end
    transaction_info += self.outputs.map do |output|
      output.amount.to_s + output.locking_script.to_s
    end
    Digest::SHA256.hexdigest transaction_info.join
  end

  def is_valid?
    self.inputs.each do |input|
      # check input is unspent
      transactions = Transactions.new
      unless transactions.unspent?(input.transaction_id, input.related_output)
        p '!!! This output is already spent !!!'
        return false
      end

      # check signature
      signature, public_key = retrieve_signature_and_public_key(input.unlocking_script)
      unless ECDSA.valid_signature?(public_key, @id, signature)
        p 'This is invalid transaction.'
        return false
      end
    end
    true
  end

  def retrieve_signature_and_public_key(unlocking_script)
    # unlocking_script form
    # signature.length + signature + 1byte-code + public_key.length + public_key
    unpacked_unlocking_script = unlocking_script.unpack('C*')
    # retrieve signature
    signature_length = unpacked_unlocking_script[0] - 1
    unpacked_signature = unpacked_unlocking_script[1..signature_length]
    signature = unpacked_signature.pack('C*')
    dec_signature = ECDSA::Format::SignatureDerString.decode(signature)
    # retrieve public_key
    public_key_length_index = signature_length + 2
    publick_key_length = unpacked_unlocking_script[public_key_length_index]
    public_key_index = public_key_length_index + 1
    unpacked_public_key = unpacked_unlocking_script[public_key_index..public_key_index+publick_key_length]
    public_key = unpacked_public_key.pack('C*')
    group = ECDSA::Group::Secp256k1
    dec_public_key = ECDSA::Format::PointOctetString.decode(public_key, group)
    return dec_signature, dec_public_key
  end
end
