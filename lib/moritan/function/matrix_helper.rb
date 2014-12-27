# coding: utf-8

module Moritan
  module MatrixHelper

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
          return [["#{b}±#{root_out}i", 1]] if denom == 1
          return [["(#{b}±#{root_out}i)/#{denom}", 1]]
        else
          ans1 = Rational(b + root_out, denom).to_integer
          ans2 = Rational(b - root_out, denom).to_integer
          return [["#{ans1}", 1], ["#{ans2}", 1]]
        end
      end

      b        = ""            if b.zero?
      root_out = ""            if root_out == 1
      root_in  = "#{root_in}i" if imaginary

      return [["#{b}±#{root_out}√#{root_in}", 1]] if denom == 1
      return [["(#{b}±#{root_out}√#{root_in})/#{denom}", 1]]

    # 重解
    rescue ZeroDivisionError
      return [["#{Rational(b, denom).to_integer}", 2]]
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
          ans = [[solution.to_integer.to_s, 1]]
          solve_equation2(aa, -bb, cc).each do |e|
            if ans[0][0] == e[0]
              ans[0][1] += e[1]
              next
            end
            ans << e
          end
          return ans
        end
        return

      when [true,true,false]
        ans_str = <<-EOS.gsub(/ {8}/,"")
        \nω = (-1+√3i)/2
        α = ∛(#{Rational(-d, a).to_integer}) としたとき
        α、 αω、 αω^2
        EOS
        return [[ans_str, 1]]
      when [false,false,true], [true,false,true]
        ans = [["0", 1]]
        solve_equation2(a, -b, c).each{|e| ans << e}
        return ans
      when [false,true,true]
        return [["0", 2], ["#{-b/a}", 1]]
      when [true,true,true]
        return [["0", 3]]
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
          raise ExceptionForMatrix::ErrNotHermitian.new("Not Hermitian Matrix")
        end
      end
      Array.new(mat.column_size){|e|e}.combination(2) do |arr|
        if mat[arr[0],arr[1]].conj != mat[arr[1],arr[0]]
          raise ExceptionForMatrix::ErrNotHermitian.new("Not Hermitian Matrix")
        end
      end
      return
    end
  end
end
