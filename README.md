FastContainer: Nginx with Haconiwa
==

This is an example of [FastContainer][fastcontainer] implementation by [nginx][nginx], [ngx_mruby][ngx_mruby] and [haconiwa][haconiwa].

[fastcontainer]: https://speakerdeck.com/matsumoto_r/fastcontainer-at-iot38
[nginx]: https://github.com/nginx/nginx
[ngx_mruby]: https://github.com/matsumotory/ngx_mruby
[haconiwa]: https://github.com/haconiwa/haconiwa

<p align="center"><img
src="https://github.com/FastContainer/nginx-haconiwa/blob/master/misc/overview-fig.png" width="400"></p>

Usage
--

To create an image to use in this implementation, run GNU make and vagrant to run the VM on the Virtualbox.

```sh
# Create nginx and container images to `./provision/dist`
$ make

# Create instance, and provision by `./provision/provisioner.sh`
$ vagrant up
```

When the VM starts up, let's start the container with the request trigger in the following way.

```sh
# HTTP container
$ curl http://127.0.0.1:8080/

# SSH container (password: screencast)
$ ssh root@127.0.0.1 -p 8022

# SMTP container
$ telnet 127.0.0.1 8025
```
