require 'securerandom'

class Transaction
  attr_accessor :id

  def initialize(id, inputs, outputs)
    @id = id
    @inputs = inputs
    @outpus = outputs
  end

  def set_id
    SecureRandom.hex(32)
  end
end
