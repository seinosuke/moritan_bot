# coding: utf-8

module Moritan
  class PCroom

    attr_reader :node_list, :status_list

    def initialize(range = 2..91, timeout:1, ssh:nil)
      raise "invalid range" unless range.is_a? Range
      @on_count = 0
      @node_list = []
      @status_list = []
      range.each do |num|
        @node_list << Moritan::PCnode.new(num, timeout:timeout)
      end
    end

    def get_status_list
      threads = []
      @node_list.each_with_index do |node,i|
        threads << Thread.new do
          @status_list[i] = node.get_status
        end
      end
      threads.each{|job| job.join}
      return @status_list
    end

    def count(symbol)
      @status_list = self.get_status_list if status_list.empty?
      counter = 0
      @status_list.each{ |node| counter += 1 if node == symbol }
      return counter
    end
  end
end
