require 'spec_helper'

describe 'apache::mod::proxy_wstunnel', :type => :class do
  it_behaves_like "a mod class, without including apache"
end
