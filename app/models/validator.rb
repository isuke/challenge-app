class Validator

  def initialize(name, value)
    @name, @value = name, value
    yield self
  end

  # nil, 長さ0, スペースのみなら例外
  def presence
    raise "#{@name}は必須項目です。" if @value.nil? or @value.delete(' ').empty?
  end

  # value以上でなければ例外
  def length_greater_than_or_equal_to(num)
    raise "#{@name}は#{num}文字以上入力してください。" if @value.length < num
  end

  # value以下でなければ例外
  def length_less_than_or_equal_to(num)
    raise "#{@name}は#{num}文字以下入力してください。" if @value.length > num
  end

  # 正規表現に一致しない場合例外
  def format(reg)
    unless @value.nil? or @value.empty? or @value =~ reg
      raise "#{@name}のフォーマットが間違っています。"
    end
  end

end
