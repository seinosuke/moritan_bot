# coding: utf-8

require 'pp'

guard :rspec, cmd: 'bundle exec rspec', title: 'テストの結果だよっ♪' do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb') { 'spec' }

  watch(/lib\/moritan\/(.+)\.rb/)           { 'spec' }
  watch(/lib\/moritan\/database\/(.+)\.rb/) { 'spec' }
  watch(/lib\/moritan\/function\/(.+)\.rb/) { 'spec' }
end
