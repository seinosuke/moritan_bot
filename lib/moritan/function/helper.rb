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
end

class Array
  def gcd
    self.inject{|a,b| a.gcd(b)}
  end
end
