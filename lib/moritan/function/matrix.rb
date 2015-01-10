# coding: utf-8

#
# 文字列で渡された行列に対する各種計算
#
# 機能名
# 1, 2
# 3, 4
#
# という形式の文字列に対して
# その行列に対する「機能名」の計算結果を返す
# 戻り値のクラスはそれぞれ違う
#

module Moritan
  module Matrix

    # 階数
    def get_rank_str(text)
      Moritan::Matrix.rank(text).to_s
    rescue NoMethodError
      return @error_message['invalid_format']
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return @error_message['invalid_format']
    end

    # 逆行列
    def get_invmat_str(text)
      mat = Moritan::Matrix.inverse(text)
      mat.row_size.times.map do |i|
        row = "\n"
        mat.row(i).each{|e| row += "#{e.to_str}, "}
        row.gsub!(/, $/,"")
      end.join
    rescue NoMethodError
      return @error_message['invalid_format']
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return @error_message['not_square']
    rescue ExceptionForMatrix::ErrNotRegular
      return @error_message['not_regular']
    end

    # 行列式
    def get_det_str(text)
      Moritan::Matrix.determinant(text).to_str
    rescue NoMethodError
      return @error_message['invalid_format']
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return @error_message['not_square']
    end

    # 固有値
    def get_eigen_str(text)
      Moritan::Matrix.eigen(text).map do |e|
        case e[1]
        when 1 then "#{e[0]}、 "
        when 2 then "#{e[0]} (重解)、 "
        when 3 then "#{e[0]} (3重解)"
        end
      end.join.sub(/、\s$/,"")
    rescue NoMethodError
      return @error_message['invalid_format']
    rescue ExceptionForMatrix::ErrNotHermitian
      return @error_message['not_hermitian']
    rescue ExceptionForMatrix::ErrDimensionMismatch
      return @error_message['not_square']
    end

    module_function

    # 階数 数値を返す
    def rank(text)
      func_name = text.split("\n")[0]
      raise NoMethodError unless func_name =~ /^階数$/
      text.sub!(/#{func_name}.?/m, "")
      text.to_mat.rank
    end

    # 逆行列 Matrixクラスのオブジェクトを返す
    def inverse(text)
      func_name = text.split("\n")[0]
      raise NoMethodError unless func_name =~ /^逆行列$/
      text.sub!(/#{func_name}.?/m, "")
      text.to_mat.inverse
    end

    # 行列式 数値を返す
    def determinant(text)
      func_name = text.split("\n")[0]
      raise NoMethodError unless func_name =~ /^行列式$/
      text.sub!(/#{func_name}.?/m, "")
      text.to_mat.determinant
    end

    # 固有値 [["解", 重複度], ["解", 重複度], …]という配列を返す
    def eigen(text)
      func_name = text.split("\n")[0]
      raise NoMethodError unless func_name =~ /^固有値$/
      text.sub!(/#{func_name}.?/m, "")
      mat = text.to_mat
 
      case [mat.column_size, mat.row_size]
      when [2, 2]
        Moritan::MatrixHelper.check_hermitian(mat) if text.index(/i/)
        b = mat[0, 0] + mat[1, 1]
        c = mat.determinant
        # どちらかが0であっても（0/1）になっているのでlcmをとれる
        bc_lcm = b.denominator.lcm(c.denominator)
        a = bc_lcm
        b = b.numerator * (bc_lcm / b.denominator)
        c = c.numerator * (bc_lcm / c.denominator)
        Moritan::MatrixHelper.solve_equation2(a, b.real, c.real)

      when [3, 3]
        Moritan::MatrixHelper.check_hermitian(mat) if text.index(/i/)
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
          e_mat.column_size.times.map{|i| ["#{e_mat[i, i]}", 1]}
        else
          solution = Moritan::MatrixHelper.solve_equation3(a, b.real, c.real, d.real)
          if solution
            solution
          else
            # eigenが対応してないっぽい
            raise NoMethodError if text.index(/i/)
            e_mat = mat.map{|e| e.real}.eigen.d
            e_mat.column_size.times.map{|i| ["#{e_mat[i, i]}", 1]}
          end
        end

      else
        e_mat = mat.map{|e| e.real}.eigen.d
        e_mat.column_size.times.map{|i| ["#{e_mat[i, i]}", 1]}
      end
    end
  end
end
