FastContainer: Nginx with Haconiwa
==

This is an example of FastContainer implementation by [nginx][nginx], [ngx_mruby][ngx_mruby] and [haconiwa][haconiwa].

[nginx]: https://github.com/nginx/nginx
[ngx_mruby]: https://github.com/matsumotory/ngx_mruby
[haconiwa]: https://github.com/haconiwa/haconiwa

Usage
--

To create an image to use in this implementation, run GNU make and vagrant to run the VM on the Virtualbox.

```sh
$ make
$ vagrant up
```

When the VM starts up, let's start the container with the request trigger in the following way.

```sh
# HTTP container
$ curl http://localhost:8080/

# SSH container
$ ssh root@127.0.0.1 -p 8022
#password: screencast

# SMTP container
$ telnet 127.0.0.1 8025
```
