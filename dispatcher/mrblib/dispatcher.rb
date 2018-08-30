def __main__(argv)
  case argv[1]
  when "version"
    puts "v#{Dispatcher::VERSION}"
  when "run"
    app = -> (env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
    Dispatcher::Server.new(host: 'localhost', port: 8000, app: app).run
  else
    puts <<-HELP
Usage: dispatcher [CMD]

Commands:
  run         run as server
  help        show this help message and exit
  version      print the version and exit
    HELP
  end
end
