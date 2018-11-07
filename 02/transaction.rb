require 'securerandom'

class Transaction
  attr_accessor :id, :inputs, :outputs

  def initialize(id, inputs, outputs)
    @id = id
    @inputs = inputs
    @outputs = outputs
  end

  def set_id
    @id = SecureRandom.hex(32)
    self
  end
end
