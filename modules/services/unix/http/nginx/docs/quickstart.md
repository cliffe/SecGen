# A QuickStart Guide to the NGINX Puppet Module

## Basic NGINX Installation and Configuration

Installing NGINX and setting up your first web host is relatively straightforward.  To install
NGINX with the puppet module, simply call the class in a puppet manifest:
```
   class{'nginx': }
```
This will install the NGINX package from the software repository of your Linux distribution, which can often be quite dated.  If you would like to install NGINX from repositories maintained by the NGINX project directly, allow the `nginx` class to manage package repositories:

```
class{'nginx':
    manage_repo => true,
    package_source => 'nginx-mainline'
}
```
The choices here are `nginx-stable` (the current 'production' level release) and `nginx-mainline` (where active development is occuring) - you can read a full explanation of the differences [here][nginxpackages].  

### Creating Your First Virtual Host

Calling the `nginx` class from your manifest simply installs the NGINX software and puts some basic configuration in place.  In this state, NGINX will not serve web pages or proxy to other services - for that, we need to define a *server*.  In NGINX terminology, a *server* is how we define our services (such as websites) with a name.  (If you are used to configuring Apache, a server is identical to an Apache *virtual host*.)  A simple virtual host that serves static web pages can be defined with a server name and a *web root*, or the directory where our HTML pages are located.

```
  nginx::resource::vhost{'www.myhost.com':
    www_root => '/opt/html/',
  }
```
In this example, the DNS address `www.myhost.com` will serve pages from the `/opt/html` directory.  The module creates some sensible defaults (such as a root location and the choice of port `*:80) with this simple definition.

### Defining a Proxy

Setting up a simple static webserver is straightforward, but is usually not the reason we implement NGINX to serve our web applications.  NGINX is a powerful *proxy* server that can manage large numbers of connections to one or more services that can serve dynamic web applications or even provide a simple technque for load balancing requests between multiple webservers.  For this example, let's define a proxy that serves a resource from a directory on our website. (A common use of this redirect may be to define a 'blog' link or a third party web application from your main site.)  We can define this proxy as follows:

```
  nginx::resource::location{'/blog':
    proxy => 'http://192.168.99.1/' ,
    vhost => 'www.myhost.com'
   }
```
This will proxy any requests made to `http://www.myhost.com/blog` to the URL `http://192.168.99.1/`.  Pay special attention to the use of `/` at the end of the URL we are proxying to - that will allow your query parameters or subfolder structure on your secondary webserver to remain intact.  

### Defining Backend Resources

We can expand on these simple proxies by defining *upstream* resources for our web applications.  Defining upstream resources allow us to define more complex scenarios such as configuration parameters, load balancing, or even the ability to share resources between virtual hosts. An upstream resource is defined with the `nginx::resource::upstream` class.  We can define a simple upstream resource by naming the resource and a single *member*.  To define an upstream resource for our previous proxy example, declare a class of type `nginx::resource::upstream` named `upstream_app`:

```
  nginx::resource::upstream { 'upstream_app':
    members => [
      '192.168.99.1:80',
    ],
  }
  ```
  This will define an upstream resource with our server IP of `192.168.99.1`.  To use the upstream in our previous proxy, modify the location block as follows:
  
  ```
    nginx::resource::location{'/blog':
    proxy => 'http://upstream_app/' ,
    vhost => 'www.myhost.com'
   }
```
Now `/blog` will proxy requests to services defined in our `upstream_app` resource.

### Putting the pieces together

Combining our configurations above into a single manifest, our code block looks like this:

```
  class{"nginx":
    manage_repo => true,
    package_source => 'nginx-mainline'

}

  nginx::resource::upstream { 'upstream_app':
    members => [
      '192.168.99.1:80',
    ],
  }

  nginx::resource::vhost{'www.myhost.com':
    www_root => '/opt/html/',
  }

  nginx::resource::location{'/proxy':
    proxy => 'http://upstream_app/' ,
    vhost => 'www.myhost.com',

  }
```  

In summary, this puppet code block will:
* Install the latest version of nginx from the 'mainline' nginx distributino.
* Define a virtual host `www.myhost.com` for our website.
* Define an *upstream* service that consists of a single external IP address.
* Define a URL that will proxy to the upstream resource.  In this case,  `http://www.myhost.com/blog` will proxy to an external resource hosted at `http://192.168.99.1`.

## References
There are a number of resources available for learning how to use NGINX effectively.  Here are a few that you may find useful:
[nginx.org][nginx]:  The NGNIX homepage.
[NGINX Documentation][ngixdocs]: Open Source NGINX Documentation
[NGINX vs. Apache][nginxvsapache]: A good article from [DigitalOcean][] describing the key differences between the use and architecture of NGINX vs. the Apache HTTPD server.  This is a good article if you are new to NGINX or want a simple overview of the NGINX event driven architecture.

[nginx]: http://ngnix.org
[phpfpm]: http://php-fpm.org
[nginxdocs]: http://nginx.org/en/docs/
[puppetlabsapache]: https://forge.puppetlabs.com/puppetlabs/apache
[digitalocean]: https://www.digitalocean.com
[nginxvsapache]: https://www.digitalocean.com/community/tutorials/apache-vs-nginx-practical-considerations