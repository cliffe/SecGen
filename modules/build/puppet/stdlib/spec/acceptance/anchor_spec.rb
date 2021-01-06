require 'spec_helper_acceptance'

describe 'anchor type' do
  describe 'success' do
    pp = <<-DOC
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
    DOC
    it 'effects proper chaining of resources' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Anchor\[final\]: Triggered 'refresh'})
      end
    end
  end
end
