require 'webrick'
require 'open-uri'
require 'nokogiri'
include WEBrick

POSTALCODE_API_PATH = 'http://zip.cgis.biz/xml/zip.php?zn='


HTTPServlet::FileHandler.add_handler("erb", HTTPServlet::ERBHandler)
s = HTTPServer.new(
 Port: 8000,
 DocumentRoot: File.join(Dir::pwd, "app/views")
)
s.config[:MimeTypes]["erb"] = "text/html"



def submit(req)
  user = User.new(req.query)
  user.save
  template = ERB.new( File.read('app/views/submit.erb') )
  template.result( binding )
end

def complation(req)
  user = User.new(req.query)
  if correct_postal_code_format?(user.postalcode)
    doc = Nokogiri::XML(open(POSTALCODE_API_PATH + user.postalcode))
    user.address = ''
    %w{state city address company}.each do |a|
      temp = doc.xpath("//ZIP_result//ADDRESS_value//value[@#{a}]").first.values.first
      user.address += temp if temp != 'none'
    end
  end
  template = ERB.new( File.read('app/views/index.erb') )
  template.result( binding )
end

def correct_postal_code_format?(postalcode)
  postalcode =~ /^[0-9]{7}$/
end

s.mount_proc('/') do |req, res|
  user = User.new
  template = ERB.new( File.read('app/views/index.erb') )
  res.body << template.result( binding )
end

s.mount_proc('/submit') do |req, res|
  p req.query
  if req.query['send']
    res.body << submit(req)
  elsif req.query['completion']
    res.body << complation(req)
  else
    raise "error"
  end
end


trap("INT"){ s.shutdown }
s.start

