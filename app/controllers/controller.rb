require 'open-uri'
require 'nokogiri'

require 'app/models/user'

class Controller < WEBrick::HTTPServlet::AbstractServlet

  # POSTALCODE_API_PATH = 'http://zip.cgis.biz/xml/zip.php?zn='
  POSTALCODE_API_PATH = 'http://zip2.cgis.biz/xml/zip.php?zn='

  def do_GET (req, res)
    @notice = Array.new
    @users = User.find_all

    user = User.new
    template = ERB.new( File.read('app/views/index.erb') )
    res.body << template.result( binding )
  end

  def do_POST (req, res)
    encode!(req.query)
    p req.query

    @notice = Array.new
    @users = User.find_all

    if req.query['send']
      res.body << submit(req)
    elsif req.query['completion']
      res.body << complation(req)
    end
  end

  private

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
        user.address = extract_address_from(doc)
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

    # XMLドキュメントから住所を抽出する。
    def extract_address_from(doc)
      address = ''
      %w{state city address company}.each do |a|
        temp = doc.xpath("//ZIP_result//ADDRESS_value//value[@#{a}]").first
        temp = temp.values.first unless temp.nil?
        address += temp if not temp.nil? and temp != 'none'
      end
      address
    end

end
