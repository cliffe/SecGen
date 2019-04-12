# Golang
Quickly and easily install the Go programming language with a customisable workspace and version.

## Usage
In order to use this module do the following:

    class { 'golang':
      version   => '1.1.2',
      workspace => '/usr/local/src/go',
    }

This will install go 1.1.2 and setup your workspace in `/usr/local/go`. Your chosen workspace should include a `bin`, `pkg` and `src` directory. The golang module doesn't create these to avoid using the wrong permissions which can cause potential issues using commands like `go get`.

If you wish to add your own code into the golang workspace but not add the files directly the best method is to create a symlink as demonstrated below:

    file { '/home/user/project':
      ensure => link,
      target => '/usr/local/src/go/src/project',
    }

Your project can then be accessed by Go:

    $ go test project

## Additional Options
The golang module supports some additional options:

    class { 'golang':
      arch => 'linux-amd64',
      download_dir => '/usr/local/src',
      download_url => 'https://company.intranet/downloads/golang.tar.gz',
    }

#### arch
The `arch` option is a string which is used in conjunction with the default `download_url`. It is the portion of the url that points to the correct architecture specific download.

#### download_dir
`download_dir` is the location in which the golang tarball is downloaded to. This is configurable in case the default (`/usr/local/src`) is unavailable.

#### download_url
This represents the url in which to download the golang tarball. The default url is made up of `version` and `arch` from the official golang downloads.

## Contributions
This module is fairly young and has only been tested on Debian. All contributions are welcome by forking the project and creating a pull request with your changes.

## Testing
When contributing please add a test/example to confirm everything still works fine.

    git clone <URL> golang
    # you will also need to puppet module install -i . <dependencies>
    cd golang
    for i in examples/*; do; puppet apply --test --noop --modulepath=.. "$i"; done

The testing is only basic, just ensure the right steps are still executed.

## Roadmap
There are still additional features which would make this module better:

1. Tests (tut, tut me for not doing them)
2. The ability to remove go
3. A Go project resource which would automatically symlink the directory?

## License

The MIT License (MIT)

Copyright (c) 2013 Darren Coxall

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
