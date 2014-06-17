class Validator

  def initialize(item)
    @item = item
    yield self
  end

  # nil, 長さ0, スペースのみなら例外
  def presence
    raise "presence error" if @item.nil? or @item.delete(' ').empty?
  end

  # value以上でなければ例外
  def length_greater_than_or_equal_to(value)
    raise "length error" if @item.length < value
  end

  # value以下でなければ例外
  def length_less_than_or_equal_to(value)
    raise "length error" if @item.length > value
  end

  # 正規表現に一致しない場合例外
  def format(reg)
    if @item.nil? and @item.empty? and not @item =~ reg
      raise "format error"
    end
  end

end
