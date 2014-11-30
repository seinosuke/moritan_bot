# coding: utf-8

module Moritan
  module Matrix

    def cal_etc(text)
      func_name = text.split("\n")[0]
      ans = "#{func_name} "
      case func_name
      when /^階数$/
        text.sub!(/#{func_name}.?/m, "")
        ans += text.to_mat.rank.to_s

      when /^逆行列$/
        text.sub!(/#{func_name}.?/m, "")
        mat = text.to_mat.inverse
        mat.row_size.times do |i|
          row = "\n"
          mat.row(i).each{|e| row += "#{e.to_integer}, "}
          row.gsub!(/, $/,"")
          ans += row
        end

      when /^行列式$/
        text.sub!(/#{func_name}.?/m, "")
        det = text.to_mat.determinant.to_integer
        ans += "#{det}"

      else 
        ans = @warning_message
      end
      return ans

    rescue NoMethodError
      return @warning_message
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return "正方行列じゃないです"
    rescue ExceptionForMatrix::ErrNotRegular
      return "正則行列じゃないです"
    rescue
      error_logs("cal_mat", $!, $@)
    end

    def cal_eigen(text)
      func_name = text.split("\n")[0]
      return @warning_message unless func_name =~ /^固有値$/
      text.sub!(/(固有値).?/m, "")
      mat = text.to_mat
      ans = "#{func_name} "
      if mat.column_size == 2 && mat.row_size == 2
        ans += eigen_2(mat)
      else
        e_mat = mat.eigen.d
        e_mat.column_size.times{|i| ans += "\n#{e_mat[i, i]}"}
      end
      return ans

    rescue NoMethodError
      return @warning_message
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return "正方行列じゃないです"
    end

    module_function

    def eigen_2(mat)
      b = (mat[0, 0] + mat[1, 1])
      c = mat.determinant
      bc_lcm = b.denominator.lcm(c.denominator)
      a = bc_lcm
      denom = a*2
      b = b.numerator * (bc_lcm / b.denominator)
      c = c.numerator * (bc_lcm / c.denominator)
      imaginary = false
      root_in = b**2 - 4*a*c
      if root_in < 0
        imaginary = true
        root_in = -root_in
      end
      primes = Prime.prime_division(root_in)
      root_out = 1
      root_in  = 1

      primes.each do |prime|
        if prime[1] == 1
          root_in *= prime[0]
        else
          root_out *= prime[0]**(prime[1]/2)
          root_in  *= prime[0] if prime[1].odd?
        end
      end

      # 約分
      loop do
        gcd = [denom, b, root_out].gcd
        break if gcd == 1
        denom    /= gcd
        b        /= gcd
        root_out /= gcd
      end

      # ルートが残らない場合
      if root_in == 1
        if imaginary
          b        = "" if b.zero?
          root_out = "" if root_out == 1
          return "#{b}±#{root_out}i" if denom == 1
          return "(#{b}±#{root_out}i)/#{denom}"
        else
          ans1 = Rational(b + root_out, denom).to_integer
          ans2 = Rational(b - root_out, denom).to_integer
          return "#{ans1}、 #{ans2}"
        end
      end

      b        = ""            if b.zero?
      root_out = ""            if root_out == 1
      root_in  = "#{root_in}i" if imaginary

      return "#{b}±#{root_out}√#{root_in}" if denom == 1
      return "(#{b}±#{root_out}√#{root_in})/#{denom}"

    rescue ZeroDivisionError
      return "#{Rational(b, denom).to_integer}"
    end
  end
end
