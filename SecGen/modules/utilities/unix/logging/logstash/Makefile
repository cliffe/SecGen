#	opensuse-121 \
#       sles-11sp3 \

default: deps lint docs

distros = \
	centos-6 \
	centos-7 \
	debian-7 \
	debian-8 \
	opensuse-13 \
	ubuntu-1204 \
	ubuntu-1404

deps: bundle-install puppet-module-deps

bundle-install:
	bundle install --path .vendor

puppet-module-deps:
	for m in puppetlabs/apt puppetlabs/stdlib darin/zypprepo ; do \
	  bundle exec puppet module install --target-dir spec/fixtures/modules --force $$m ; \
	done
	touch spec/fixtures/manifests/site.pp

docs:
	bundle exec puppet strings

lint:
	bundle exec rake lint
	bundle exec rake validate
	# bundle exec rubocop spec Rakefile

test-unit: deps lint
	bundle exec rake spec_verbose

test-acceptance: $(distros)

$(distros):
	BEAKER_set=$@ bundle exec rake beaker

clean:
	rm -f spec/fixtures/artifacts/logstash*
	rm -f spec/fixtures/artifacts/puppet-enterprise*
	rm -f files/*.deb
	rm -f files/*.gem
	rm -f files/*.rpm
	rm -rf log
	rm -rf package

release: clean docs
	puppet module build
