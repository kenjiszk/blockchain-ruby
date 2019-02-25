require './wallet.rb'
require './blockchain.rb'
require 'faraday'

class WalletServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    wallet = Wallet.new
    wallet.load
    if wallet.public_key
      transactions = Transactions.new
      transactions.load_all
      balance = transactions.balance(wallet.address)
      res.body = wallet.address + " " + balance.to_s
      res.status = 200
    else
      res.status = 404
    end
  end
  def do_POST(req, res)
    wallet = Wallet.new
    wallet.create_key
    wallet.save
    res.body = wallet.address
    res.status = 201
  end
end

class GenesisBlockServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    db = Database.new
    begin
      db.restore("last_hash")
      res.status = 400
    rescue StandardError
      wallet = Wallet.new
      wallet.load
      blockchain = Blockchain.new
      blockchain.create_genesis_block(wallet)
      last_hash = db.restore("last_hash")
      res.body = last_hash
      res.status = 201
    end
  end
end

class BlockchainServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    db = Database.new
    if db.exist_in_local?(req.query['key'])
      if req.query['key'] == "last_hash"
        hash = db.restore(req.query['key'])
        res.body = Marshal.dump(db.restore(hash))
      else
        res.body = Marshal.dump(db.restore(req.query['key']))
      end
    else
      res.status = 404
    end
  end
end

class UpdateBlockchainServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    host = req.query['node'] || ENV['NODE1']
    api_res = Faraday.get "http://" + host + ":8000/blockchain", {key: "last_hash"}
    last_block = Marshal.load(api_res.body)
    last_hash = last_block.hash

    db = Database.new
    blockchain = Blockchain.new
    unless db.exist_in_local?(last_hash)
      unless blockchain.is_genesis_block(last_block)
        pow = ProofOfWork.new(last_block)
        return unless pow.validate
      end
      db.save('last_hash', last_hash)
      db.save(last_hash, last_block)
    else
      return
    end

    prev_block_hash = last_block.prev_block_hash
    while prev_block_hash != ""
      api_res = Faraday.get "http://" + ENV['NODE1'] + ":8000/blockchain", {key: prev_block_hash}
      block = Marshal.load(api_res.body)
      if db.exist_in_local?(block.hash)
        break
      else
        unless blockchain.is_genesis_block(block)
          pow = ProofOfWork.new(block)
          return unless pow.validate
        end
        db.save(block.hash, block)
        prev_block_hash = block.prev_block_hash
      end
    end
    transactions = Transactions.new
    transactions.delete_mem_pool
  end
end

class PayServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    to = req.query['to']
    amount = req.query['amount']

    wallet = Wallet.new
    wallet.load
    new_transaction = wallet.pay(to, 10)
    transactions = Transactions.new
    if new_transaction.is_valid?
      transactions.add_to_mem_pool new_transaction
    end

    dumped_new_transaction = Marshal.dump(new_transaction)
    Faraday.post "http://" + ENV['NODE1'] + ":8000/transaction", {transaction: dumped_new_transaction}
    Faraday.post "http://" + ENV['NODE2'] + ":8000/transaction", {transaction: dumped_new_transaction}
  end
end

class TransactionServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    transaction = Marshal.load(req.query['transaction'])

    transactions = Transactions.new
    if transaction.is_valid?
      transactions.add_to_mem_pool transaction
    end
  end
end

class StartPowServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    transactions = Transactions.new
    transactions.load_all

    if transactions.mem_pool.count > 0
      blockchain = Blockchain.new
      wallet = Wallet.new
      wallet.load
      blockchain.create_block(transactions.mem_pool, wallet.address)
      transactions.delete_mem_pool

      Faraday.post "http://" + ENV['NODE1'] + ":8000/update_blockchain", {node: ENV['ME']}
      Faraday.post "http://" + ENV['NODE2'] + ":8000/update_blockchain", {node: ENV['ME']}
    end
  end
end
