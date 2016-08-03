# Protocols module
This module installs protocols with a security vulnerability.

## Requirements
- puppetlabs-java puppet module
- gentoken puppet module

## How to use this module

## Creating your own insecure protocols
In the extra's folder is the file `SkeletonProtocol.java` which can be used to make new protocols in the future.

The source code of the new module should be placed inside the directory `templates/dirty`. The file extension `.erb` should be appended to the end of the filename (i.e. `SkeletonProtocol.java.erb`). Inside this file, you should put `<%= @token %>` where you would like the token to be placed in the compiled version of the code. Ensure that there are no cases where there are symbols next to greater than or less than signs or else puppet may not be able to convert the template correctly.

A new folder should be created in `files/clean` with the name of your new protocol. Any files that the student requires to break the protocol should be placed in this folder (with any hex keys removed/tokens).

## Example node definition
This is the node definition I have been using to test this module. I may change this example in the future to something more useful.

```puppet
node 'local.vm'{
  class { 'protocols':
    protocols => "ex31:Lutescent,ex32:Olivaceous,ex33:Purpure,ex34:Titian",
  }
}
```

## How this module works
- Copies the specified protocol source code to the /root/tmp directory.

- Compiles all of the protocols, and then encrypts the class file.

- All source code is deleted and the encrypted class files are copied to `/root`

- A protocol loader is compiled and copied to the root directory. The protocol loader is used to establish the connection and to decrypt the encrypted protocols in memory.

- A copy of the clean code is copied over into `/home/charlie`.
