# coding: utf-8

require File.expand_path(Dir.home + '/bot/moritan_bot/spec/spec_helper')

describe Moritan::Matrix do
  let(:text) { "#{func_name}\n#{matrix_str}" }

  shared_examples 'raise ErrDimensionMismatch' do
    it { expect { is_expected }.to raise_error(ExceptionForMatrix::ErrDimensionMismatch) }
  end

  shared_examples 'raise ErrNotRegular' do
    it { expect { is_expected }.to raise_error(ExceptionForMatrix::ErrNotRegular) }
  end

  shared_context '正方行列でない行列' do
    let(:matrix_str) do
      <<-EOM.gsub(/ {6}/,"")
      1, 2, 3
      4, 5, 6
      EOM
    end
  end

  shared_context '正則でない行列' do
    let(:matrix_str) do
      <<-EOM.gsub(/ {6}/,"")
      1, 1
      0, 0
      EOM
    end
  end

  #
  # 階数
  #
  describe '::rank' do
    let(:func_name) { '階数' }
    subject { Moritan::Matrix.rank(text) }

    context '2次正則行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0
        0, 1
        EOM
      end
      it { is_expected.to eq 2 }
    end

    context '2次正方行列で正則でない場合' do
      include_context '正則でない行列'
      it { is_expected.to eq 1 }
    end

    context '零行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        0, 0
        0, 0
        EOM
      end
      it { is_expected.to eq 0 }
    end

    context '不正な形である場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 2, 3
        4, 5, 6, 7
        EOM
      end
      it_behaves_like 'raise ErrDimensionMismatch'
    end
  end # ::rank

  #
  # 逆行列
  #
  describe '::inverse' do
    let(:func_name) { '逆行列' }
    subject { Moritan::Matrix.inverse(text) }

    context '2次正則行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0
        0, 1
        EOM
      end
      ans = Matrix[[1, 0], [0, 1]].map(&:to_c)
      it { is_expected.to eq ans }
    end

    context '正方行列でない場合' do
      include_context '正方行列でない行列'
      it_behaves_like 'raise ErrDimensionMismatch'
    end

    context '正則行列でない場合' do
      include_context '正則でない行列'
      it_behaves_like 'raise ErrNotRegular'
    end
  end # ::inverse

  #
  # 行列式
  #
  describe '::determinant' do
    let(:func_name) { '行列式' }
    subject { Moritan::Matrix.determinant(text) }

    context '2次正則行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        2, 1
        1, 3
        EOM
      end
      it { is_expected.to eq 5 }
    end

    context '正則行列でない場合' do
      include_context '正則でない行列'
      it { is_expected.to eq 0 }
    end

    context '正方行列でない場合' do
      include_context '正方行列でない行列'
      it_behaves_like 'raise ErrDimensionMismatch'
    end
  end # ::determinant

  #
  # べき乗
  #
  describe '::inverse' do
    let(:func_name) { '2乗' }
    subject { Moritan::Matrix.power(text) }

    context '2次正則行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0
        0, 1
        EOM
      end
      ans = Matrix[[1, 0], [0, 1]].map(&:to_c)
      it { is_expected.to eq ans }
    end

    context '正方行列でない場合' do
      include_context '正方行列でない行列'
      it_behaves_like 'raise ErrDimensionMismatch'
    end
  end # ::power

  #
  # 固有値
  #
  describe '::eigen' do
    let(:func_name) { '固有値' }
    subject { Moritan::Matrix.eigen(text) }

    context '0の3重解となる場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        0, 0, 0
        0, 0, 0
        0, 0, 0
        EOM
      end
      it { is_expected.to eq [["0", 3]] }
    end

    context '-1の3重解となる場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        -4, 3, -1
        -6, 5, -2
        -9, 9, -4
        EOM
      end
      it { is_expected.to eq [["-1", 3]] }
    end

    context '重解を含む場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 2 ,1
        -1, 4, 1
        2, -4, 0
        EOM
      end
      it { is_expected.to eq [["1", 1], ["2", 2]] }
    end

    context '階数が1(0の重解)の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 1, 1
        2, 2, 2
        3, 3, 3
        EOM
      end
      it { is_expected.to eq [["0", 2], ["6", 1]] }
    end

    context '階数が2の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0, 0
        0, 1, 0
        0, 0, 0
        EOM
      end
      it { is_expected.to eq [["0", 1], ["1", 2]] }
    end

    context '階数が2の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0, 0
        0, 3, 0
        0, 0, 0
        EOM
      end
      it { is_expected.to eq [["0", 1], ["3", 1], ["1", 1]] }
    end

    context '階数が2の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 2, 3
        1, 4, 0
        0, 0, 0
        EOM
      end
      it { is_expected.to eq [["0", 1], ["(5±√17)/2", 1]] }
    end

    context '単位行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0, 0
        0, 1, 0
        0, 0, 1
        EOM
      end
      it { is_expected.to eq [["1", 3]] }
    end

    context '3次正則行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0, 0
        0, 2, 0
        0, 0, 3
        EOM
      end
      it { is_expected.to eq [["1", 1], ["3", 1], ["2", 1]] }
    end

    context '成分に分数を含む3次正則行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1/3, 0, 0
        0, 1/3, 11/9
        0, 1/4, 2/3
        EOM
      end
      it { is_expected.to eq [["1/3", 1], ["(3±2√3)/6", 1]] }
    end

    context '3重根をとる場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        0, 0, 1
        1, 0, 0
        0, 1, 0
        EOM
      end
      ans_str = "\nω = (-1+√3i)/2\nα = ∛(1) としたとき\nα、 αω、 αω^2\n"
      it { is_expected.to eq [[ans_str, 1]] }
    end

    context '2次のエルミート行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        2, 3-i
        3+i, 1
        EOM
      end
      it { is_expected.to eq [["(3±√41)/2", 1]] }
    end

    context '3次のエルミート行列の場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 0, 3-i
        0, 1, 0
        3+i, 0, 1
        EOM
      end
      it { is_expected.to eq [["1", 1], ["1±√10", 1]] }
    end

    context 'find_solutionが成功しなかった場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 2, 3
        4, 5, 6
        7, 8, -9
        EOM
      end
      ans = [["-0.424881965312478", 1], ["10.05933172129617", 1], ["-12.6344497559837", 1]]
      it { is_expected.to eq ans }
    end

    context 'エルミート行列でfind_solutionが成功しなかった場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, 2-2/3i, 1+2i
        2+2/3i, 4, 1+2i
        1-2i, 1-2i, 3
        EOM
      end
      it { expect { is_expected }.to raise_error(NoMethodError) }
    end

    context '成分に虚数を含む行列でエルミート行列でない場合' do
      let(:matrix_str) do
        <<-EOM.gsub(/ {8}/,"")
        1, i
        0, 1
        EOM
      end
      it { expect { is_expected }.to raise_error(ExceptionForMatrix::ErrNotHermitian) }
    end

    context '正方行列でない場合' do
      include_context '正方行列でない行列'
      it_behaves_like 'raise ErrDimensionMismatch'
    end
  end # ::eigen
end
