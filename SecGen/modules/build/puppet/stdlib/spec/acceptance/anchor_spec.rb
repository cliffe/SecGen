require 'spec_helper_acceptance'

describe 'anchor type' do
  describe 'success' do
    it 'should effect proper chaining of resources' do
      pp = <<-EOS
      class anchored {
        anchor { 'anchored::begin': }
        ~> anchor { 'anchored::end': }
      }

      class anchorrefresh {
        notify { 'first': }
        ~> class { 'anchored': }
        ~> anchor { 'final': }
      }

      include anchorrefresh
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Anchor\[final\]: Triggered 'refresh'/)
      end
    end
  end
end
