def gem_config(conf)
  conf.gem github: 'iij/mruby-socket'
  conf.gem github: 'matsumotory/mruby-mutex'
  conf.gem github: 'matsumotory/mruby-fast-remote-check'
  conf.gem github: 'mattn/mruby-http'
  conf.gem github: 'katzer/mruby-shelf'
  conf.gem github: 'haconiwa/haconiwa', checksum_hash: ENV['HACONIWA_VERSION'], branch: 'master'
  conf.gem File.expand_path(File.dirname(__FILE__))
end

MRuby::Build.new do |conf|
  toolchain :gcc
  gem_config(conf)
end
