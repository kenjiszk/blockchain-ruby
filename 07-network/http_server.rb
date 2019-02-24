require 'webrick'
require './servlets.rb'

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '0.0.0.0',
  :Port => 8000
})

server.mount('/wallet', WalletServlet)

Signal.trap('INT'){server.shutdown}
server.start
