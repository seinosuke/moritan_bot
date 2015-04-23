# coding: utf-8

module Moritan
  class PCnode

    attr_reader :node_num, :node_num_str, :addr, :status

    def initialize(num, timeout:1)
      @node_num = num
      @timeout  = timeout

      case @node_num.to_s.size
      when 1 then @node_num_str = '00' + @node_num.to_s
      when 2 then @node_num_str = '0'  + @node_num.to_s
      else raise "invalid node_num"
      end
      @addr = "esys-pc#{@node_num_str}.edu.esys.tsukuba.ac.jp"
    end

    def on?
      Net::Ping::External.new(@addr, nil, @timeout).ping?
    end

    def get_status
      @status ||= :on if self.on?
      @status ||= :off
      return @status
    end
  end
end
