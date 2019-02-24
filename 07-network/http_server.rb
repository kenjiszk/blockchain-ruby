require 'webrick'
require './servlets.rb'

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '0.0.0.0',
  :Port => 8000
})

server.mount('/wallet', WalletServlet)
server.mount('/genesis_block', GenesisBlockServlet)
server.mount('/blockchain', BlockchainServlet)
server.mount('/update_blockchain', UpdateBlockchainServlet)

Signal.trap('INT'){server.shutdown}
server.start
