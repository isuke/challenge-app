#!/usr/bin/env ruby

require 'webrick'
include WEBrick

$LOAD_PATH << File.expand_path('../', __FILE__)
require 'app/controllers/controller'

HTTPServlet::FileHandler.add_handler("erb", HTTPServlet::ERBHandler)
server = HTTPServer.new(
 Port: 8000,
 DocumentRoot: File.join(Dir::pwd, "app/views")
)
server.config[:MimeTypes]["erb"] = "text/html"

server.mount "/", Controller

trap("INT"){ server.shutdown }

server.start
