#!/usr/bin/env ruby
require 'webrick'
require 'sqlite3'
include WEBrick
include SQLite3

$LOAD_PATH << File.expand_path('../', __FILE__)
require 'app/models/user'

HTTPServlet::FileHandler.add_handler("erb", HTTPServlet::ERBHandler)
s = HTTPServer.new(
 Port: 8000,
 DocumentRoot: File.join(Dir::pwd, "app/views")
)
s.config[:MimeTypes]["erb"] = "text/html"


User.create_table


s.mount_proc('/submit') do |req, res|
  p req.query
  user = User.new(req.query)
  user.save
  template = ERB.new( File.read('app/views/submit.erb') )
  res.body << template.result( binding )
end

trap("INT"){ s.shutdown }
s.start

