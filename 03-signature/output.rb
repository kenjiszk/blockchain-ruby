class Output
  attr_accessor :amount, :locking_script

  def initialize(amount, locking_script)
    @amount = amount
    @locking_script = locking_script
  end
end
