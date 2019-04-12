# Version 3.1.0

Adding in the following faetures/functionality

- Docker Stack support on Windows.

# Version 3.0.0

Various fixes for github issues
- 206
- 226
- 241
- 280
- 281
- 287
- 289
- 294
- 303
- 312
- 314

Adding in the following features/functionality

-Support for multiple compose files.

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/issues?q=is%3Aissue+milestone%3AV3.0.0+is%3Aclosed)


# Version 2.0.0

Various fixes for github issues
- 193
- 197
- 198
- 203
- 207
- 208
- 209
- 211
- 212
- 213
- 215
- 216
- 217
- 218
- 223
- 224
- 225
- 228
- 229
- 230
- 232
- 234
- 237
- 243
- 245
- 255
- 256
- 259

Adding in the following features/functionality

- Ability to define swarm clusters in Hiera.
- Support docker compose file V2.3.
- Support refresh only flag.
- Support for Docker healthcheck and unhealthy container restart.
- Support for Docker on Windows:
    - Add docker ee support for windows server 2016.
    - Docker image on Windows.
    - Docker run on Windows.
    - Docker compose on Windows.
    - Docker swarm on Windows.
    - Add docker exec functionality for docker on windows.
    - Add storage driver for Windows.  

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/2?closed=1)


# Version 1.1.0

Various fixes for Github issues
- 183
- 173
- 173
- 167
- 163
- 161

Adding in the following features/functionality

- IPv6 support
- Define type for docker plugins

A full list of issues and PRs associated with this release can be found [here](https://github.com/puppetlabs/puppetlabs-docker/milestone/1?closed=1)


# Version 1.0.5

Various fixes for Github issues
- 98
- 104
- 115
- 122
- 124

Adding in the following features/functionality

- Removed all unsupported OS related code from module
- Removed EPEL dependency
- Added http support in compose proxy
- Added in rubocop support and i18 gem support
- Type and provider for docker volumes
- Update apt module to latest
- Added in support for a registry mirror
- Facts for docker version and docker info
- Fixes for $pass_hash undef
- Fixed typo in param.pp
- Replaced deprecated stblib functions with data types

# Version 1.0.4

Correcting changelog

# Version 1.0.3
Various fixes for Github issues
 - 33
 - 68
 - 74
 - 77
 - 84

Adding in the following features/functionality:

 - Add tasks to update existing service
 - Backwards compatible TMPDIR
 - Optional GPG check on repos
 - Force pull on image tag 'latest'
 - Add support for overlay2.override_kernel_check setting
 - Add docker network fact
 - Add pw hash for registry login idompodency
 - Additional flags for creating a network
 - Fixing incorrect repo url for redhat

# Version 1.0.2
Various fixes for Github issues
 - 9
 - 11
 - 15
 - 21
Add tasks support for Docker Swarm

# Version 1.0.1
Updated metadata and CHANGELOG

# Version 1.0.0
Forked for garethr/docker v5.3.0
Added support for:
- Docker services within a swarm cluster
- Swarm mode
- Docker secrets
