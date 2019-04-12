require 'puppet/provider/elastic_yaml'

# Provider to help manage file-based Shield/X-Pack user/role configuration
# files.
class Puppet::Provider::ElasticUserRoles < Puppet::Provider::ElasticYaml
  # Override the ancestor `parse` method to process a users/roles file
  # managed by the Elasticsearch user tools.
  def self.parse(text)
    text.split("\n").map(&:strip).select do |line|
      # Strip comments
      not line.start_with? '#' and not line.empty?
    end.map do |line|
      # Turn array of roles into array of users that have the role
      role, users = line.split(':')
      users.split(',').map do |user|
        { user => [role] }
      end
    end.flatten.inject({}) do |hash, user|
      # Gather up user => role hashes by append-merging role lists
      hash.merge(user) { |_, o, n| o + n }
    end.map do |user, roles|
      # Map those hashes into what the provider expects
      {
        :name => user,
        :roles => roles
      }
    end.to_a
  end

  # Represent this user/role record as a correctly-formatted config file.
  def self.to_file(records)
    debug "Flushing: #{records.inspect}"
    records.map do |record|
      record[:roles].map do |r|
        { [record[:name]] => r }
      end
    end.flatten.map(&:invert).inject({}) do |acc, role|
      acc.merge(role) { |_, o, n| o + n }
    end.delete_if do |_, users|
      users.empty?
    end.map do |role, users|
      "#{role}:#{users.join(',')}"
    end.join("\n") + "\n"
  end

  def self.skip_record?(_record)
    false
  end
end
