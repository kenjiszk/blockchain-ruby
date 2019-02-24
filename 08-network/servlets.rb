require './wallet.rb'
require './blockchain.rb'
require 'faraday'

class WalletServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    wallet = Wallet.new
    wallet.load
    if wallet.public_key
      res.body = wallet.address
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
    api_res = Faraday.get "http://" + ENV['NODE1'] + ":8000/blockchain", {key: "last_hash"}
    last_block = Marshal.load(api_res.body)
    last_hash = last_block.hash

    db = Database.new
    unless db.exist_in_local?(last_hash)
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
        db.save(block.hash, block)
        prev_block_hash = block.prev_block_hash
      end
    end
  end
end
