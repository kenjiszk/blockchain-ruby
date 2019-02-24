require './wallet.rb'

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
