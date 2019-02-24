class WalletServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.status = 200
  end
  def do_POST(req, res)
    res.status = 201
  end
end
