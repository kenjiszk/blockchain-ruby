require './database.rb'

class Transactions
  attr_accessor :all, :mem_pool

  def initialize()
    @all = []
    @mem_pool = []
    @key = "transactions"
  end

  def load_all
    db = Database.new
    # load mem pool transactions
    begin
      @mem_pool = db.restore(@key)
    rescue StandardError
      @mem_pool = []
    end
    @all = Marshal.load(Marshal.dump(@mem_pool))

    # load mined transactions
    last_hash = db.restore('last_hash')
    while last_hash != '' do
      last_block = db.restore(last_hash)
      @all += last_block.transactions
      last_hash = last_block.prev_block_hash
    end
  end

  def add_to_mem_pool(transaction)
    db = Database.new
    begin
      @mem_pool = db.restore(@key)
    rescue StandardError
      @mem_pool = []
    end
    @mem_pool.push transaction
    db.save(@key, @mem_pool)
  end

  def delete_mem_pool
    @mem_pool = []
    db = Database.new
    db.save(@key, @mem_pool)
  end

  def collect_enough_utxo(address, pay_amount)
    utxo = {}
    amounts = 0
    load_all
    @all.each do |transaction|
      transaction.outputs.each.with_index do |output, output_index|
        if owner?(output, address)
          if unspent?(transaction.id, output_index)
            utxo[transaction.id] = [] if utxo[transaction.id].nil?
            utxo[transaction.id].push output_index
            amounts += output.amount
          end
        end
        if pay_amount != nil
          return utxo, amounts if amounts >= pay_amount
        end
      end
    end
    return utxo, amounts
  end

  def balance(address)
    _, amounts = collect_enough_utxo(address, nil)
    amounts
  end

  def owner?(output, address)
    output.locking_script == address
  end

  def unspent?(transaction_id, output_index)
    @all.each do |transaction|
      transaction.inputs.each do |input|
        next if input.nil?
        if input.transaction_id == transaction_id && input.related_output == output_index
          return false
        end
      end
    end
    true
  end

  def get_transaction_by(id)
    @all.each do |transaction|
      return transaction if transaction.id == id
    end
    return nil
  end
end
