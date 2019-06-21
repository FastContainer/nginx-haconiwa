# coding: utf-8
# frozen_string_literal: true

HACONIWA_BIN_PATH = '/usr/bin/haconiwa'
IMAGES_ROOT = '/tmp/criu/images'
CleanSpawn.cgroup_root_path = '/sys/fs/cgroup/systemd'

module Container
  class << self
    def dispatch_http
      containers = conf['containers']['http']
      req = Nginx::Request.new
      haco, cip = if containers.include?(req.hostname)
          [containers[req.hostname]['haco'], containers[req.hostname]['ip']]
        else
          [containers['default']['haco'], containers['default']['ip']]
        end
      dispatch(haco, cip, 80, [], req.hostname)
    end

    def forward_to_netdata
      containers = conf['containers']['http']
      req = Nginx::Request.new
      "#{containers[req.hostname]['ip']}:19999"
    end

    def dispatch_ssh
      containers = conf['containers']['ssh']
      haco = containers['haco']
      cip = containers['ip']
      cport = 22
      c = Nginx::Stream::Connection.new 'dynamic_server'
      c.upstream_server = "#{cip}:#{cport}"
      dispatch(haco, cip, cport)
    end

    def dispatch_smtp_no_auth(name)
      containers = conf['containers']['smtp']
      haco = containers[name]['haco']
      cip = containers[name]['ip']
      cport = 25
      c = Nginx::Stream::Connection.new 'dynamic_server'
      c.upstream_server = "#{cip}:#{cport}"
      dispatch(haco, cip, cport)
    end

    def dispatch_smtp_after_smtp_auth
      containers = conf['containers']['smtp']
      req = Nginx::Request.new

      user = req.headers_in['Auth-User']
      prot = req.headers_in['Auth-Protocol']
      cip = containers[user]['ip']
      haco = containers[user]['haco']
      cport = 25
      result = "#{cip}:#{cport}"

      req.headers_out['Auth-Status'] = -> do
        unless containers.keys.include? user
          debug("SMTP AUTH failed: unknown #{user}")
          return 'invalid user'
        end

        req.headers_out['Auth-Server'] = cip
        req.headers_out['Auth-Port'] = "#{cport}"
        dispatch(haco, cip, cport)

        debug("SMTP AUTH success: #{user} to #{result}")
        return 'OK'
      end.call

      return result
    end

    def dispatch(haco = nil, ip = nil, port = nil, env = [], hostname = '')
      raise "Not enough container info -- haco: #{haco}, ip: #{ip} port: #{port}" \
        if haco.nil? || ip.nil? || port.nil?

      if ! File.exist?(IMAGES_ROOT + "/apache/core-1.img")
        return Dispatcher.new(ip, port, haco, env, hostname).run
      else
        return Dispatcher.new(ip, port, haco, env, hostname).restore
      end
    rescue => e
      err(e.message)
      return ''
    end

    def debug(m)
      Nginx.errlogger Nginx::LOG_DEBUG, "#{self.name} -- #{m}"
    rescue
      Nginx::Stream.log Nginx::Stream::LOG_DEBUG, "#{self.name} -- #{m}"
    end

    def err(m)
      Nginx.errlogger Nginx::LOG_ERR, "#{self.name} -- #{m}"
    rescue
      Nginx::Stream.log Nginx::Stream::LOG_ERR, "#{self.name} -- #{m}"
    end

    def conf
      @@_conf ||= load_conf
    end

    def load_conf
      path = '/etc/nginx/conf.d/spec.yml'
      io = File.open(path, 'r')
      Container.debug("Loaded conf: #{path}")
      YAML.load(io.read)
    end
  end

  class Dispatcher
    def initialize(ip, port, haco, env = [], hostname = '')
      @ip = ip
      @port = port
      @haco = haco

      @root = '/var/lib/haconiwa'
      @id = "#{@haco}-#{@ip.gsub('.', '-')}-#{Time.now.to_i}"
      # @id = "#{@haco}-#{@ip.gsub('.', '-')}-1540895210"
      @environment = ["IP=#{@ip}", "PORT=#{@port}", "ID=#{@id}", "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"]
      @environment.concat(env) if env.length > 0
      @hostname = hostname
    end

    def run
      result = "#{@ip}:#{@port}"
      if listen?
        Container.debug('Already container launched!')
        return result
      end

      Container.debug('Launching a container...')
      setup_rootfs
      start_haconiwa
      wait_for_listen("/var/lock/.#{@id}.hacolock")

      Container.debug("Return ip: #{@ip} port: #{@port}")
      return result
    end

    def restore
      result = "#{@ip}:#{@port}"
      if listen?
        Container.debug('Already container launched!')
        return result
      end

      Container.debug('Restoreing a container...')

      restore_haconiwa
      wait_for_listen("/var/lock/.#{@id}.hacolock")

      Container.debug("Return ip: #{@ip} port: #{@port}")
      result
    end

    def setup_rootfs
      rootfs = "#{@root}/rootfs/#{@id}"
      return if File.exist?(rootfs)
      system "/bin/mkdir -m 755 -p #{rootfs}"
      system "/bin/tar xfp #{@root}/images/#{@haco}.image.tar -C #{rootfs}"
      setup_hosts(rootfs)
      setup_welcome_html(rootfs) if @haco == 'nginx'
    end

    def setup_hosts(root)
      cmd = [
        "/bin/echo \"127.0.0.1 localhost #{@id}\" >> #{root}/etc/hosts",
        "/bin/cat /data/hosts >> #{root}/etc/hosts"
      ].join(' && ')
      Container.debug(cmd)
      system cmd
    end

    def setup_welcome_html(root)
      html = "#{root}/var/www/html/index.nginx-debian.html"
      cmd = ['/bin/sed', '-i', "'s/Welcome to nginx!/Welcome to #{@hostname}/g'", html].join(' ')
      Container.debug(cmd)
      system cmd
    end

    def env
      @environment.unshift('/usr/bin/env').join(' ')
    end

    def command
      [env, HACONIWA_BIN_PATH, 'start', "#{@root}/hacos/#{@haco}.haco"].join(' ')
    end

    def restore_command
      [env, HACONIWA_BIN_PATH, 'restore', "#{@root}/hacos/#{@haco}.haco"].join(' ')
    end

    def start_haconiwa
      shell = ['/bin/bash', '-c', "#{command} >> /var/log/nginx/haconiwa.log 2>&1"]
      Container.debug(shell.join(' '))
      clean_spawn(*shell)
    end

    def restore_haconiwa
      shell = ['/bin/bash', '-c', "#{restore_command} >> /var/log/nginx/haconiwa.log 2>&1"]
      Container.debug(shell.join(' '))
      clean_spawn(*shell)
    end

    def wait_for_listen(lockfile, max = 1000000)
      while true
        listen = listen?
        file = File.exist?(lockfile)

        return if listen && file
        Container.debug("Stil no listen: #{@ip}:#{@port}") unless listen
        Container.debug("Stil no lockfile: #{lockfile}'") unless file

        usleep 10 * 1000
        max -= 1
        raise 'It take too long time to begin listening, timeout' if max <= 0
      end
    end

    def listen?
      Container.debug("FastRemoteCheck start")
      if ret = ::FastRemoteCheck.new('127.0.0.1', 0, @ip, @port, 3).connectable?
        Container.debug("FastRemoteCheck ok")
      else
        Container.debug("FastRemoteCheck ng")
      end
      ret
    rescue => e
      Container.debug("FastRemoteCheck error: #{e.message} retry")
      false
    end
  end
end

def nginx_local_port
  Nginx::Stream::Connection.local_port
rescue
  req = Nginx::Request.new
  req.var.server_port.to_i
end

lambda do
  return case nginx_local_port
         when 58080 then Container.dispatch_smtp_after_smtp_auth
         when 58025 then Container.dispatch_smtp_no_auth('noauth1')
         when 58026 then Container.dispatch_smtp_no_auth('noauth2')
         when 58027 then Container.dispatch_smtp_no_auth('noauth3')
         when 58028 then Container.dispatch_smtp_no_auth('noauth4')
         when 19998 then Container.forward_to_netdata
         when 80 then Container.dispatch_http
         when 8022 then Container.dispatch_ssh
         end
end.call
