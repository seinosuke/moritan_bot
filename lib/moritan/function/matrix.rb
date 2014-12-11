# coding: utf-8

class ExceptionForMatrix::ErrNotHermitian < StandardError; end

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
          mat.row(i).each{|e| row += "#{e.visualize}, "}
          row.gsub!(/, $/,"")
          ans += row
        end

      when /^行列式$/
        text.sub!(/#{func_name}.?/m, "")
        det = text.to_mat.determinant.visualize
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

      case [mat.column_size, mat.row_size]
      when [2, 2]
        hermitian_check(mat) if text.index(/i/)
        b = mat[0, 0] + mat[1, 1]
        c = mat.determinant
        # どちらかが0であっても（0/1）になっているのでlcmをとれる
        bc_lcm = b.denominator.lcm(c.denominator)
        a = bc_lcm
        b = b.numerator * (bc_lcm / b.denominator)
        c = c.numerator * (bc_lcm / c.denominator)
        ans += solve_equation2(a, b.real, c.real)

      when [3, 3]
        hermitian_check(mat) if text.index(/i/)
        b = -(mat[0,0] + mat[1,1] + mat[2,2])
        c = mat[0,0]*mat[1,1] + mat[1,1]*mat[2,2] + mat[2,2]*mat[0,0] -
            mat[0,1]*mat[1,0] - mat[1,2]*mat[2,1] - mat[2,0]*mat[0,2]
        d = -mat.determinant
        bcd_lcm = [b.denominator, c.denominator, d.denominator].lcm
        a = bcd_lcm
        b = b.numerator * (bcd_lcm / b.denominator)
        c = c.numerator * (bcd_lcm / c.denominator)
        d = d.numerator * (bcd_lcm / d.denominator)
        if (a.to_s.size + d.to_s.size) > 12
          e_mat = mat.map{|e| e.real}.eigen.d
          ans += "\n#{e_mat[0,0]}\n#{e_mat[1,1]}\n#{e_mat[2,2]}"
        elsif solve_equation3(a, b.real, c.real, d.real)
          ans += solve_equation3(a, b.real, c.real, d.real)
        else
          # eigenが対応してないっぽい
          return "その答えはまだ返せません" if text.index(/i/)
          e_mat = mat.map{|e| e.real}.eigen.d
          ans += "\n#{e_mat[0,0]}\n#{e_mat[1,1]}\n#{e_mat[2,2]}"
        end

      else
        e_mat = mat.map{|e| e.real}.eigen.d
        e_mat.column_size.times{|i| ans += "\n#{e_mat[i, i]}"}
      end
      return ans

    rescue NoMethodError
      return @warning_message
    rescue ExceptionForMatrix::ErrNotHermitian
      return "成分に複素数を含む行列の固有値計算はエルミート行列のみ対応しています"
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return "正方行列じゃないです"
    end

    module_function

    # 2次方程式を解く
    def solve_equation2(a, b, c)
      denom = a*2
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
      denom, b, root_out = [denom, b, root_out].abbrev

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

    # 重解
    rescue ZeroDivisionError
      return "#{Rational(b, denom).to_integer} (重解)"
    end

    # 3次方程式を解く
    def solve_equation3(a, b, c, d)
      # puts "#{a}λ^3 + #{b}λ^2 + #{c}λ + #{d} = 0"
      case [b.zero?, c.zero?, d.zero?]
      when [false,false,false], [true,false,false], [false,true,false]
        solution = find_solution(a, b, c, d)
        if solution
          aa = a / (solution.denominator)
          cc = d / (-solution.numerator)
          bb = (solution.denominator*cc - c) / (solution.numerator)
          # puts "#{aa}λ^2 + #{bb}λ + #{cc}"
          ans1 = solution.to_integer.to_s
          ans2 = solve_equation2(aa, -bb, cc).gsub("\s\(重解\)","")
          # ans2にans1が含まれてたら重解表示する感じにしたい（予定）
          return "#{ans1} (3重解)" if ans1 == ans2
          return "#{ans1}、 #{ans2}"
        end
        return

      when [true,true,false]
        ans = "\nω = (-1+√3i)/2" +
              "\nα = ∛(#{Rational(-d, a).to_integer}) としたとき" +
              "\nα、 αω、 αω^2"
        return ans
      when [false,false,true], [true,false,true]
        return "0、 #{solve_equation2(a, -b, c)}"
      when [false,true,true]
        return "0 (重解)、 #{-b/a}"
      when [true,true,true]
        return "0 (3重解)"
      else
        return
      end
    end

    # 有理数の解を見つける
    def find_solution(a, b, c, d)
      a.divisor_list.each do |a_divisor|
        d.divisor_list.each do |d_divisor|
          temp = Rational(d_divisor, a_divisor)
          return  temp if (a*(temp**3)    + b*(temp**2)    + c*temp + d) == 0
          return -temp if (a*((-temp)**3) + b*((-temp)**2) - c*temp + d) == 0
        end
      end
      return
    end

    # エルミート行列であるか調べる
    def hermitian_check(mat)
      mat.column_size.times do |n|
        if mat[n,n].imag != 0
          raise ExceptionForMatrix::ErrNotHermitian.new("not unitary")
        end
      end
      Array.new(mat.column_size){|e|e}.combination(2) do |arr|
        if mat[arr[0],arr[1]].conj != mat[arr[1],arr[0]]
          raise ExceptionForMatrix::ErrNotHermitian.new("not unitary")
        end
      end
      return
    end
  end
end
