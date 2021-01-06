#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'bool2num function' do
  describe 'success' do
    %w[false f 0 n no].each do |bool|
      pp1 = <<-DOC
        $input = "#{bool}"
        $output = bool2num($input)
        notify { "$output": }
      DOC
      it "should convert a given boolean, #{bool}, to 0" do
        apply_manifest(pp1, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{Notice: 0})
        end
      end
    end

    %w[true t 1 y yes].each do |bool|
      pp2 = <<-DOC
        $input = "#{bool}"
        $output = bool2num($input)
        notify { "$output": }
      DOC
      it "should convert a given boolean, #{bool}, to 1" do
        apply_manifest(pp2, :catch_failures => true) do |r|
          expect(r.stdout).to match(%r{Notice: 1})
        end
      end
    end
  end
end
