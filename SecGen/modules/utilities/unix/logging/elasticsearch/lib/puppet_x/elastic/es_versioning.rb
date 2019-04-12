module Puppet_X
  module Elastic
    # Assists with discerning the locally installed version of Elasticsearch.
    # Implemented in a way to be called from native types and providers in order
    # to lazily fetch the package version from various arcane Puppet mechanisms.
    class EsVersioning
      # All of the default options we'll set for Elasticsearch's command
      # invocation.
      DEFAULT_OPTS = {
        'home' => 'ES_HOME',
        'logs' => 'LOG_DIR',
        'data' => 'DATA_DIR',
        'work' => 'WORK_DIR',
        'conf' => 'CONF_DIR'
      }.freeze

      # Create an array of command-line flags to append to an `elasticsearch`
      # startup command.
      def self.opt_flags(package_name, catalog, opts = DEFAULT_OPTS.dup)
        opt_flag = opt_flag(min_version('5.0.0', package_name, catalog))

        opts.delete 'work' if min_version '5.0.0', package_name, catalog
        opts.delete 'home' if min_version '5.4.0', package_name, catalog

        opt_args = if min_version '6.0.0', package_name, catalog
                     []
                   else
                     opts.map do |k, v|
                       "-#{opt_flag}default.path.#{k}=${#{v}}"
                     end.sort
                   end

        opt_args << '--quiet' if min_version '5.0.0', package_name, catalog

        [opt_flag, opt_args]
      end

      # Get the correct option flag depending on whether Elasticsearch is post
      # version 5.
      def self.opt_flag(v5_or_later)
        v5_or_later ? 'E' : 'Des.'
      end

      # Predicate to determine whether a package is at least a certain version.
      def self.min_version(ver, package_name, catalog)
        Puppet::Util::Package.versioncmp(
          version(package_name, catalog), ver
        ) >= 0
      end

      # Fetch the package version for a locally installed package.
      def self.version(package_name, catalog)
        if (es_pkg = catalog.resource("Package[#{package_name}]"))
          es_pkg.provider.properties[:version] || es_pkg.provider.properties[:ensure]
        else
          raise Puppet::Error, "could not find `Package[#{package_name}]` resource"
        end
      end
    end
  end
end
