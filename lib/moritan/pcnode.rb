# coding: utf-8

module Moritan
  class PCnode

    attr_reader :node_num, :node_num_str, :addr, :status

    def initialize(num, timeout:1, ssh:nil)
      @node_num = num
      @timeout  = timeout
      @ssh      = ssh
      @pre_addr = "ubuntu.u.tsukuba.ac.jp"

      case @node_num.to_s.size
      when 1 then @node_num_str = '00' + @node_num.to_s
      when 2 then @node_num_str = '0'  + @node_num.to_s
      else raise "invalid node_num"
      end
      @addr = "esys-pc#{@node_num_str}.edu.esys.tsukuba.ac.jp"
    end

    def on?
      Net::SSH.start(@pre_addr, @ssh[:username], @ssh[:opt]) do |s|
        s.exec!("ping -w #{@timeout} #{@addr}") do |channel, stream, data|
          if stream == :stdout
            return false if data =~ /0 received/
          end
          raise "connect error" if stream == :stderr
        end
      end
      return true
    rescue
      error_logs("esysPinger")
      return false
    end

    def get_status
      @status ||= :on if self.on?
      @status ||= :off
      return @status
    end
  end
end
