require 'webrick'
include WEBrick


HTTPServlet::FileHandler.add_handler("erb", HTTPServlet::ERBHandler)
s = HTTPServer.new(
 Port: 8000,
 DocumentRoot: File.join(Dir::pwd, "app/views")
)
s.config[:MimeTypes]["erb"] = "text/html"


s.mount_proc('/submit') do |req, res|
  p req.query
  user = User.new(req.query)
  user.save
  template = ERB.new( File.read('app/views/submit.erb') )
  res.body << template.result( binding )
end

trap("INT"){ s.shutdown }
s.start

