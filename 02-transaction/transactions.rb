require './database.rb'
  
class Transactions
  attr_accessor :all

  def initialize()
    @all = []
    @key = "transactions"
  end

  def load_all
    db = Database.new
    @all = db.restore(@key)
  end

  def create_first_transaction(wallets)
    input = Input.new(nil, nil, 'This is first transaction')
    output = Output.new(1000, wallets[:Alis].address)
    @all.push Transaction.new(nil, [input], [output]).set_id
    db = Database.new
    db.save(@key, @all)
  end

  def save
    db = Database.new
    db.save(@key, @all)
  end

  def collect_enough_utxo(address, pay_amount)
    utxo = {}
    amounts = 0
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

  def balance(address)
    _, amounts = collect_enough_utxo(address, nil)
    amounts
  end
end
