def gem_config(conf)
  #conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem File.expand_path(File.dirname(__FILE__))
end

MRuby::Build.new do |conf|
  toolchain :gcc

  conf.gem mgem: 'mruby-io'
  conf.gem mgem: 'mruby-env'
  conf.gem mgem: 'mruby-dir'
  conf.gem mgem: 'mruby-digest'
  conf.gem mgem: 'mruby-process'
  conf.gem mgem: 'mruby-pack'
  conf.gem mgem: 'mruby-socket'
  conf.gem mgem: 'mruby-json'
  conf.gem mgem: 'mruby-onig-regexp'
  conf.gem mgem: 'mruby-redis'
  conf.gem mgem: 'mruby-vedis'
  conf.gem mgem: 'mruby-sleep'
  conf.gem mgem: 'mruby-userdata'
  conf.gem mgem: 'mruby-uname'
  conf.gem mgem: 'mruby-httprequest'
  conf.gem mgem: 'mruby-mutex'
  conf.gem mgem: 'mruby-localmemcache'
  conf.gem mgem: 'mruby-base64'
  conf.gem mgem: 'mruby-fast-remote-check'
  conf.gem github: 'haconiwa/haconiwa'

  gem_config(conf)
end
