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

      ans = case [mat.column_size, mat.row_size]
        when [2, 2]
          hermitian_check(mat) if text.index(/i/)
          b = mat[0, 0] + mat[1, 1]
          c = mat.determinant
          # どちらかが0であっても（0/1）になっているのでlcmをとれる
          bc_lcm = b.denominator.lcm(c.denominator)
          a = bc_lcm
          b = b.numerator * (bc_lcm / b.denominator)
          c = c.numerator * (bc_lcm / c.denominator)
          solve_equation2(a, b.real, c.real).map do |e|
            case e[1]
            when 1 then "#{e[0]}、 "
            when 2 then "#{e[0]} (重解)"
            end
          end.join.sub(/、\s$/,"")

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
            e_mat.column_size.times.map{|i| "\n#{e_mat[i, i]}"}.join
          elsif solve_equation3(a, b.real, c.real, d.real)
            solve_equation3(a, b.real, c.real, d.real).map do |e|
              case e[1]
              when 1 then "#{e[0]}、 "
              when 2 then "#{e[0]} (重解)、 "
              when 3 then "#{e[0]} (3重解)"
              end
            end.join.sub(/、\s$/,"")
          else
            # eigenが対応してないっぽい
            return "その答えはまだ返せません" if text.index(/i/)
            e_mat = mat.map{|e| e.real}.eigen.d
            e_mat.column_size.times.map{|i| "\n#{e_mat[i, i]}"}.join
          end

        else
          e_mat = mat.map{|e| e.real}.eigen.d
          e_mat.column_size.times.map{|i| "\n#{e_mat[i, i]}"}.join
        end

      return "#{func_name} #{ans}"

    rescue NoMethodError
      return @warning_message
    rescue ExceptionForMatrix::ErrNotHermitian
      return "成分に複素数を含む行列の固有値計算はエルミート行列のみ対応しています"
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return "正方行列じゃないです"
    end
  end
end
