def __main__(argv)
  case argv[1]
  when "version"
    puts "v#{Dispatcher::VERSION}"
  when "run"
    Dispatcher::Server.new.run
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
