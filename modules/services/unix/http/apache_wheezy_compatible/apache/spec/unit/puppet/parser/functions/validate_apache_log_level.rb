#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the validate_apache_log_level function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("validate_apache_log_level")).to eq("function_validate_apache_log_level")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_validate_apache_log_level([]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should raise a ParseError when given garbage" do
    expect { scope.function_validate_apache_log_level(['garbage']) }.to( raise_error(Puppet::ParseError) )
  end

  it "should not raise a ParseError when given a plain log level" do
    expect { scope.function_validate_apache_log_level(['info']) }.to_not raise_error 
  end

  it "should not raise a ParseError when given a log level and module log level" do
    expect { scope.function_validate_apache_log_level(['warn ssl:info']) }.to_not raise_error 
  end

  it "should not raise a ParseError when given a log level and module log level" do
    expect { scope.function_validate_apache_log_level(['warn mod_ssl.c:info']) }.to_not raise_error 
  end

  it "should not raise a ParseError when given a log level and module log level" do
    expect { scope.function_validate_apache_log_level(['warn ssl_module:info']) }.to_not raise_error 
  end

  it "should not raise a ParseError when given a trace level" do
    expect { scope.function_validate_apache_log_level(['trace4']) }.to_not raise_error 
  end

end
