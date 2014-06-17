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
  begin
    user = User.new(req.query)
    user.save
    @users << user
    @notice << "保存しました。"
  rescue => e
    @notice << e.message
  end
  template = ERB.new( File.read('app/views/index.erb') )
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

def encode!(hash, code="UTF-8")
  hash.each do |k,v|
    hash[k] = v.force_encoding(code)
  end
  hash
end

def index (req)
  user = User.new
  template = ERB.new( File.read('app/views/index.erb') )
  template.result( binding )
end

s.mount_proc('/') do |req, res|
  encode!(req.query)
  p req.query

  @notice = Array.new
  @users = User.find_all

  if req.query['send']
    res.body << submit(req)
  elsif req.query['completion']
    res.body << complation(req)
  else
    res.body << index(req)
  end
end


trap("INT"){ s.shutdown }
s.start

