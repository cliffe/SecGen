# Usage of Hiera

Passing through parameters from the main Class[nginx] and then having them chain down to Class[nginx::config] creates a ton of unnecessary spaghetti code that makes the module more complex to understand and difficult to extend.

Going forward, it is recommended to declare your changes in Hiera based on the system(s) role and location in your environment. In Puppet < 3.x, this is accomplished with Hiera bindings.

## Example Conversion

Say for a moment that you have this code block:

```ruby
class { 'nginx':
  gzip => false,
}
```

Moving this to hiera is simple. First, identify the appropriate hiera level to apply this attribute. (A node or role level is recommended). Then, add the following codeblock...

```yaml
---
  nginx::config::gzip: false
```

Magically, it's all done! Work through these until the deprecation notices go away.

## I (cannot/do not want to) use Hiera

Maybe for some reason, Hiera isn't being used in your organization. Or, you like to keep a certain amount of composibilty in you modules. Or, hidden option #3! Regardless, the recommended path is to instantiate your own copy of Class[nginx::config] and move on with life. Let's do another example.

Assume you have the following code block:

```ruby
class { 'nginx' :
  manage_repo   => false,
  confd_purge   => true,
  vhost_purge   => true,
}
```

This should become...

```ruby
Anchor['nginx::begin']
->
class { 'nginx::config' :
  confd_purge   => true,
  vhost_purge   => true,
}

class { 'nginx' :
  manage_repo   => false,
}
```

The order in which this commands are parsed is important, since nginx looks for nginx::config via a defined(nginx::config) statement, which as of puppet 3.x is still parse-order dependent.

# Why again are you doing this?

Well, the fact of the matter, the old Package/Config/Service pattern has served us well, but times are a-changin. Many users are starting to manage their packages and service seperately outside of the traditional pattern (Docker, anyone?). This means that in order to stay true to the goals of Configuration Management, it is becoming necessary to make less assumptions about how an organizations graph is composed, and allow the end-user additional flexibility. This is requring a re-think about how to best consume this module.


