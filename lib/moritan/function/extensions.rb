# coding: utf-8

# 指定のフォーマットの文字列を成分がComplexである行列にして返す
class String
  def to_mat
    return nil if self.empty? || self.index(/\./)
    rows = NKF.nkf('-m0 -Z1 -w', self).split("\n")
    rows.each_with_index do |row, i|
      return nil unless row.index(/,|，|、/)
      rows[i] = row.split(/,|，|、/)
    end
    return Matrix.rows(rows, false).map(&:to_c)
  end
end

# 分母が1のものを整数にする
class Rational
  def to_integer
    return self.numerator if self.denominator == 1
    return self
  end
end

# 例えば(3+0i)を3にする(後でちゃんと書き直すかも)
class Complex
  def to_str
    return "0" if self.real == 0 && self.imag == 0
    return "#{self.imag.to_r.to_integer}i" if self.real == 0
    return "#{self.real.to_r.to_integer}" if self.imag == 0
    return "#{self.numerator}" if self.denominator == 1
    return "(#{self.numerator})/#{self.denominator}"
  end
end

class Integer
  def divided?(num)
    return self%num == 0 ? true : false
  end

  # 全ての正の約数の配列を返す
  def divisor_list
    num = -self if self < 0
    num ||= self
    return [1] if num == 1
    Prime.prime_division(num).map do |e|
      Array.new(e[1]+1).map.with_index{|_, i| e[0]**i}
    end.inject{|p,q| p.product(q)}.map do |a|
      [a].flatten.inject(&:*)
    end.sort
  rescue ZeroDivisionError
    return
  end
end

class Array
  def gcd
    self.inject{|a,b| a.gcd(b)}
  end

  def lcm
    self.inject{|a,b| a.lcm(b)}
  end

  #
  # 要素数1の配列を渡すと全て[1]になる
  # 要素が全て0の配列を渡すとnilを返す
  # 要素に0が含まれていてもそれ以外の要素同士で作用する
  #
  def abbrev
    gcd = self.gcd
    self.map{|e| e/=gcd}
  rescue ZeroDivisionError
    return
  end
end
