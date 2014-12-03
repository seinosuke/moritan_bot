# coding: utf-8

class String
  def to_mat
    return nil if self.empty?
    rows = NKF.nkf('-m0 -Z1 -w', self).split("\n")
    rows.each_with_index do |row, i|
      return nil if row.index(/\+|＋/)
      return nil unless row.index(/,|，|、/)
      rows[i] = row.split(/,|，|、/)
    end
    return Matrix.rows(rows, false).map(&:to_r)
  end
end

class Rational
  def to_integer
    return self.numerator if self.denominator == 1
    return self
  end
end

class Integer
  def divided?(num)
    return self%num == 0 ? true : false
  end

  def divisor_list
    num = -self if self < 0
    num ||= self
    return [1] if num == 1
    Prime.prime_division(num).map do |e|
      Array.new(e[1]+1).map.with_index do |element, i|
        e[0]**i
      end
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
end
