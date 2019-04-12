# Custom extensions namespace
module Puppet_X
  # Elastic helpers
  module Elastic
    # Utility extension for consistent to_yaml behavior.
    module SortedHash
      # Upon extension, modify the hash appropriately to render
      # sorted yaml dependent upon whichever way is supported for
      # this version of Puppet/Ruby's yaml implementation.
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def self.extended(base)
        if RUBY_VERSION >= '1.9'
          # We can sort the hash in Ruby >= 1.9 by recursively
          # re-inserting key/values in sorted order. Native to_yaml will
          # call .each and get sorted pairs back.
          tmp = base.to_a.sort
          base.clear
          tmp.each do |key, val|
            if val.is_a? base.class
              val.extend Puppet_X::Elastic::SortedHash
            elsif val.is_a? Array
              val.map do |elem|
                if elem.is_a? base.class
                  elem.extend(Puppet_X::Elastic::SortedHash)
                else
                  elem
                end
              end
            end
            base[key] = val
          end
        else
          # Otherwise, recurse into the hash to extend all nested
          # hashes with the sorted each_pair method.
          #
          # Ruby < 1.9 doesn't support any notion of sorted hashes,
          # so we have to expressly monkey patch each_pair, which is
          # called by ZAML (the yaml library used in Puppet < 4; Puppet
          # >= 4 deprecates Ruby 1.8)
          #
          # Note that respond_to? is used here as there were weird
          # problems with .class/.is_a?
          base.merge! base do |_, ov, _|
            if ov.respond_to? :each_pair
              ov.extend Puppet_X::Elastic::SortedHash
            elsif ov.is_a? Array
              ov.map do |elem|
                if elem.respond_to? :each_pair
                  elem.extend Puppet_X::Elastic::SortedHash
                else
                  elem
                end
              end
            else
              ov
            end
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # Override each_pair with a method that yields key/values in
      # sorted order.
      def each_pair
        keys.sort.each do |key|
          yield key, self[key]
        end
      end
    end
  end
end
