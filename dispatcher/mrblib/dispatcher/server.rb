module Dispatcher
  class Server
    def run(host = '127.0.0.1', port = 8888)
      tcp = TCPServer.open(host, port)
      socks = [tcp]
      addr = tcp.addr
      puts tcp.addr
      addr.shift
      puts "server is on #{addr.join(":")}"

      loop do
        nsock = IO.select(socks)
        next if nsock == nil
        for s in nsock[0]
          if s == tcp
            socks << s.accept
            puts "#{s} is accepted"
          else
            if s.eof?
              puts "#{s} is gone"
              socks.delete(s)
            else
              str = s.gets
              puts "#{s}: #{str}"
              s.write(str)
            end
          end
        end
      end
    end
  end
end
