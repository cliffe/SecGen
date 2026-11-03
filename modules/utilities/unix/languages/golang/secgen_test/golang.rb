require_relative '../../../../../lib/post_provision_test'

class GolangTest < PostProvisionTest
  def initialize
    self.module_name = 'golang'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No read_facts or default inputs: nothing to parameterise. golang.pp pins
  # Go 1.9 (now linux-amd64), so 'go1.9' is the module's fixed intent.
  def test_module
    super
    tier(1) do
      test_local_command('go installed?', 'test -d /usr/local/go && echo ok', 'ok')
      test_local_command('go binary present', 'test -x /usr/local/go/bin/go && echo ok', 'ok')
      test_local_command('gofmt binary present', 'test -x /usr/local/go/bin/gofmt && echo ok', 'ok')
      test_local_command('curl installed?', 'dpkg -l curl | grep -E "^ii"', 'curl')
      test_local_command('mercurial installed?', 'dpkg -l mercurial | grep -E "^ii"', 'mercurial')
      test_local_command('profile.d script sets GOPATH', 'cat /etc/profile.d/golang.sh', 'GOPATH=')
      test_local_command('profile.d script adds go to PATH', 'cat /etc/profile.d/golang.sh', '/usr/local/go/bin')
      test_local_command('profile.d script is executable', 'test -x /etc/profile.d/golang.sh && echo ok', 'ok')
    end
    tier(2) do
      test_command_succeeds('go version', '/usr/local/go/bin/go version')
      test_local_command('go version reports 1.9', '/usr/local/go/bin/go version', 'go1.9')
      # login shell picks go up from /etc/profile.d
      test_local_command('go on PATH for an unprivileged login shell', 'go version', 'go1.9', user: 'nobody')
      test_local_command('go builds and runs a program',
                         'd=$(mktemp -d) && cd $d && printf \'package main\nimport "fmt"\nfunc main() { fmt.Println("hello-go") }\n\' > h.go && go run h.go',
                         'hello-go', user: 'nobody')
      test_command_succeeds('hg (mercurial) runs', 'hg --version')
    end
  end
end

GolangTest.new.run
