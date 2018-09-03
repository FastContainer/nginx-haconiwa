# coding: utf-8
# frozen_string_literal: true

CleanSpawn.cgroup_root_path = "/sys/fs/cgroup/systemd"

module Container
  class << self
    def dispatch(haco = nil, ip = nil, port = nil)
      raise "Not enough container info -- haco: #{haco}, ip: #{ip} port: #{port}" \
        if haco.nil? || ip.nil? || port.nil?
      return Dispatcher.new(ip, port).run(haco)
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
  end

  class Dispatcher
    def initialize(ip, port)
      @ip = ip
      @port = port
    end

    def run(haco)
      result = "#{@ip}:#{@port}"
      return result if listen?

      cmd = ['/usr/bin/haconiwa', 'run', "/var/lib/haconiwa/hacos/#{haco}.haco"].join(' ')
      shell_cmd = ['/bin/bash', '-c', "#{cmd} >> /var/log/nginx/haconiwa.log 2>&1"]
      ::Container.debug("Launch a container: #{shell_cmd.join(' ')}")
      clean_spawn(*shell_cmd)
      wait_for_listen("/var/lock/.#{haco}.hacolock")

      ::Container.debug("Return ip: #{@ip} port: #{@port}")
      return result
    end

    def wait_for_listen(lockfile, max = 300)
      while true
        listen = listen?
        file = File.exist?(lockfile)

        return if listen && file
        ::Container.debug("Stil no listen: #{@ip}:#{@port}") unless listen
        ::Container.debug("Stil no lockfile: #{lockfile}'") unless file

        usleep 100 * 1000
        max -= 1
        raise 'it take too long time to begin listening, timeout' if max <= 0
      end
    end

    def listen?
      ::FastRemoteCheck.new('127.0.0.1', 0, @ip, @port, 3).connectable?
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
  when 8022
    haco = 'ssh'
    cip = '10.0.5.3'
  when 8025
    haco = 'postfix'
    cip = '10.0.5.4'
  when 8587
    haco = 'postfix'
    cip = '10.0.5.4'
  when 8465
    haco = 'postfix'
    cip = '10.0.5.4'
  end

  if port == 80
    cport = port
  else
    cport = port - 8000
    c = Nginx::Stream::Connection.new 'dynamic_server'
    c.upstream_server = "#{cip}:#{cport}"
  end

  return Container.dispatch(haco, cip, cport)
end.call
