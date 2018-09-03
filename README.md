FastContainer: Nginx with Haconiwa
==

This is an example of [FastContainer][fastcontainer] implementation by [nginx][nginx], [ngx_mruby][ngx_mruby] and [haconiwa][haconiwa].

[fastcontainer]: https://speakerdeck.com/matsumoto_r/fastcontainer-at-iot38
[nginx]: https://github.com/nginx/nginx
[ngx_mruby]: https://github.com/matsumotory/ngx_mruby
[haconiwa]: https://github.com/haconiwa/haconiwa

![overview](misc/overview-fig.png)

Requirement
--

- docker >= 18.06.0-ce
- vagrant >= 2.1.1

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
$ printf "%s\0%s\0%s" foo foo password | openssl base64 -e
YmFyAGJhcgBwYXNzd29yZA==
$ telnet 127.0.0.1 8025
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 ubuntu-xenial ESMTP ready
HELO local
250 ubuntu-xenial
AUTH PLAIN YmFyAGJhcgBwYXNzd29yZA==
235 2.0.0 OK

$ printf "%s\0%s\0%s" foo foo password | openssl base64 -e
Zm9vAGZvbwBwYXNzd29yZA==
$ telnet 127.0.0.1 8025
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 ubuntu-xenial ESMTP ready
HELO local
250 ubuntu-xenial
AUTH PLAIN Zm9vAGZvbwBwYXNzd29yZA==
235 2.0.0 OK
```

Todo
--

- [ ] Multitenancy
- [ ] Auto Scaling
- [ ] Multi Host

Author
--

- [linyows][linyows]

[linyows]: https://github.com/linyows

License
--

This project is under the MIT License.

- nginx: https://github.com/nginx/nginx/blob/master/docs/text/LICENSE
- ngx_mruby: https://github.com/matsumotory/ngx_mruby/blob/master/MITL
- haconiwa: https://github.com/haconiwa/haconiwa/blob/master/LICENSE
