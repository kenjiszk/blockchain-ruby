require 'webrick'
require './servlets.rb'

server = WEBrick::HTTPServer.new({ 
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000
})

server.mount('/wallet', WalletServlet)

Signal.trap('INT'){server.shutdown}
server.start
