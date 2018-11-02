class Input
  def initialize(transaction_id, related_output, unlocking_script)
    @transaction_id = transaction_id
    @related_output = related_output
    @unlocking_script = unlocking_script
  end
end
