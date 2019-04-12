# Contributing

If you have a bugfix or new feature that you would like to contribute to this puppet module, please find or open an issue about it first.
Talk about what you would like to do - it may be that somebody is already working on it, or that there are particular issues that you should know about before implementing the change.

**Note**: If you have support-oriented questions that aren't a bugfix or feature request, please post your questions on the [discussion forums](https://discuss.elastic.co/c/elasticsearch).

We enjoy working with contributors to get their code accepted.
There are many approaches to fixing a problem and it is important to find the best approach before writing too much code.

The process for contributing to any of the Elastic repositories is similar.

## The Contributor License Agreement

Please make sure you have signed the [Contributor License Agreement](http://www.elastic.co/contributor-agreement/).
We are not asking you to assign copyright to us, but to give us the right to distribute your code without restriction.
We ask this of all contributors in order to assure our users of the origin and continuing existence of the code.
You only need to sign the CLA once.

## Development Setup

There are a few testing prerequisites to meet:

* Ruby.
  As long as you have a recent version with `bundler` available, `bundler` will install development dependencies.

You can then install the necessary gems with:

    bundle install

This will install the requisite rubygems for testin.

* Docker.
  Note that Docker is used to run tests that require a Linux container/VM - if you only need to run simple rspec/doc tests, this shouldn't be necessary.
  If you are developing on a Linux machine with a working Docker instance, this should be sufficient.
  On OS X, just use the official [Docker installation method](https://docs.docker.com/engine/installation/mac/) to get a working `docker` setup.
  Confirm that you can communicate with the Docker hypervisor with `docker version`.

## Testing

Running through the tests on your own machine can get ahead of any problems others (or Jenkins) may run into.

First, run the intake tests and ensure it completes without errors with your changes.
These are lightweight tests that verify syntax, style, and all other tests that do not require a container to run.

    bundle exec rake intake

Next, run the more thorough acceptance tests.
For example, to run the acceptance tests against CentOS 7, run the following:

    bundle exec rake beaker:centos-7-x64

The final output line will tell you which, if any, tests failed.
Note that you can find all other container acceptance tests with the `bundle exec rake -T` command.

## Opening Pull Requests

In summary, to open a new PR:

* Sign the Contributor License Agreement
* Run the tests to confirm everything works as expected
* Rebase your changes.
  Update your local repository with the most recent code from this puppet module repository, and rebase your branch on top of the latest master branch.
* Submit a pull request
  Push your local changes to your forked copy of the repository and submit a pull request.
  In the pull request, describe what your changes do and mention the number of the issue where discussion has taken place, eg "Closes #123".

Then sit back and wait!
There will probably be discussion about the pull request and, if any changes are needed, we would love to work with you to get your pull request merged into this puppet module.
