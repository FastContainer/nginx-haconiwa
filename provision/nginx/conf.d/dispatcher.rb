# coding: utf-8
# frozen_string_literal: true

CleanSpawn.cgroup_root_path = '/sys/fs/cgroup/systemd'

module Container
  class << self
    def dispatch_smtp_after_smtp_auth
      containers = Container.conf['containers']['smtp']
      req = Nginx::Request.new

      user = req.headers_in['Auth-User']
      prot = req.headers_in['Auth-Protocol']
      ip = containers[user]['ip']
      port = 25
      result = "#{ip}:#{port}"

      req.headers_out['Auth-Status'] = -> do
        unless containers.keys.include? user
          debug("SMTP AUTH failed: unknown #{user}")
          return 'invalid user'
        end

        req.headers_out['Auth-Server'] = ip
        req.headers_out['Auth-Port'] = "#{port}"

        dispatch('postfix', ip, port)

        debug("SMTP AUTH success: #{user} to #{result}")
        return 'OK'
      end.call

      return result
    end

    def dispatch_http
      containers = Container.conf['containers']['http']
      req = Nginx::Request.new
      haco, cip = if containers.include?(req.hostname)
          [containers[req.hostname]['haco'], containers[req.hostname]['ip']]
        else
          [containers['default']['haco'], containers['default']['ip']]
        end
      Container.dispatch(haco, cip, 80)
    end

    def dispatch_ssh
      containers = Container.conf['containers']['ssh']
      haco = containers['haco']
      cip = containers['ip']
      cport = 22
      c = Nginx::Stream::Connection.new 'dynamic_server'
      c.upstream_server = "#{cip}:#{cport}"
      Container.dispatch(haco, cip, cport)
    end

    def dispatch(haco = nil, ip = nil, port = nil)
      raise "Not enough container info -- haco: #{haco}, ip: #{ip} port: #{port}" \
        if haco.nil? || ip.nil? || port.nil?

      result = "#{ip}:#{port}"
      return result if listen?(ip, port)

      debug('Launch a container')
      run(haco, ip, port)
      debug("Return ip: #{ip} port: #{port}")
      return result

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

    def run(haco, ip, port)
      root = '/var/lib/haconiwa'
      id = "#{haco}-#{ip.gsub('.', '-')}"
      setup_rootfs(root, haco, id)
      run_haconiwa(ip, port, root, haco, id)
      wait_for_listen("/var/lock/.#{id}.hacolock", ip, port)
    end

    def setup_rootfs(root, haco, id)
      rootfs = "#{root}/rootfs/#{id}"
      return if File.exist?(rootfs)
      system "/bin/mkdir -m 755 -p #{rootfs}"
      system "/bin/tar xfp #{root}/images/#{haco}.image.tar -C #{rootfs}"
    end

    def run_haconiwa(ip, port, root, haco, id)
      env = '/usr/bin/env'
      envs = [env, "IP=#{ip}", env, "PORT=#{port}", env, "ID=#{id}"].join(' ')
      cmd = [envs, '/usr/bin/haconiwa', 'run', "#{root}/hacos/#{haco}.haco"].join(' ')
      shell_cmd = ['/bin/bash', '-c', "#{cmd} >> /var/log/nginx/haconiwa.log 2>&1"]
      debug(shell_cmd.join(' '))
      clean_spawn(*shell_cmd)
    end

    def wait_for_listen(lockfile, ip, port, max = 100)
      while true
        listen = listen?(ip, port)
        file = File.exist?(lockfile)

        return if listen && file
        debug("Stil no listen: #{ip}:#{port}") unless listen
        debug("Stil no lockfile: #{lockfile}'") unless file

        usleep 100 * 10000
        max -= 1
        raise 'it take too long time to begin listening, timeout' if max <= 0
      end
    end

    def listen?(ip, port)
      ::FastRemoteCheck.new('127.0.0.1', 0, ip, port, 3).connectable?
    rescue => e
      debug("FastRemoteCheck error: #{e.message}")
      false
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
         when 80 then Container.dispatch_http
         when 8022 then Container.dispatch_ssh
         end
end.call
