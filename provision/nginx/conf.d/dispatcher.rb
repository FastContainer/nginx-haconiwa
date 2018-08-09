# coding: utf-8
# frozen_string_literal: true

CleanSpawn.cgroup_root_path = "/sys/fs/cgroup/systemd"

module Container
  class << self
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
      cmd = ['/usr/bin/haconiwa', 'run', "/var/lib/haconiwa/hacos/#{haco}.haco"].join(' ')
      shell_cmd = ['/bin/bash', '-c', "#{cmd} >> /var/log/nginx/haconiwa.log 2>&1"]
      debug(shell_cmd.join(' '))
      clean_spawn(*shell_cmd)
      wait_for_listen("/var/lock/.#{haco}.hacolock", ip, port)
    end

    def wait_for_listen(lockfile, ip, port, max = 600)
      while true
        listen = listen?(ip, port)
        file = File.exist?(lockfile)

        return if listen && file
        debug("Stil no listen: #{ip}:#{port}") unless listen
        debug("Stil no lockfile: #{lockfile}'") unless file

        usleep 100 * 1000
        max -= 1
        raise 'it take too long time to begin listening, timeout' if max <= 0
      end
    end

    def listen?(ip, port)
      ::FastRemoteCheck.new('127.0.0.1', 0, ip, port, 3).connectable?
    rescue
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
  port = nginx_local_port

  case port
  when 80
    haco = 'nginx'
    cip = '10.0.5.2'
    cport = 80
  when 8022
    haco = 'ssh'
    cip = '10.0.5.3'
    cport = 22
  when 8025
    haco = 'postfix'
    cip = '10.0.5.4'
    cport = 25
  when 8587
    haco = 'postfix'
    cip = '10.0.5.4'
    cport = 587
  when 8465
    haco = 'postfix'
    cip = '10.0.5.4'
    cport = 465
  end

  if port != 80
    c = Nginx::Stream::Connection.new 'dynamic_server'
    c.upstream_server = "#{cip}:#{cport}"
  end

  return Container.dispatch(haco, cip, cport)
end.call
