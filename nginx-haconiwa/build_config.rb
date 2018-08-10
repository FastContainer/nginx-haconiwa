MRuby::Build.new('host') do |conf|
  toolchain :gcc

  conf.gembox 'full-core'

  conf.cc do |cc|
    cc.flags << '-fPIC' if ENV['BUILD_DYNAMIC_MODULE']
    cc.flags << ENV['NGX_MRUBY_CFLAGS'] if ENV['NGX_MRUBY_CFLAGS']
  end

  # Recommended for ngx_mruby
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
  conf.gem mgem: 'mruby-socket'
  conf.gem mgem: 'mruby-fast-remote-check'
  conf.gem github: 'udzura/mruby-clean-spawn'
  conf.gem github: 'AndrewBelt/mruby-yaml'
  # ngx_mruby extended class
  conf.gem './mrbgems/ngx_mruby_mrblib'
  conf.gem './mrbgems/rack-based-api'
end

MRuby::Build.new('test') do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  conf.gem mgem: 'mruby-simplehttp'
  conf.gem mgem: 'mruby-httprequest'
  conf.gem mgem: 'mruby-uname'
  conf.gem mgem: 'mruby-ngx-mruby-ext'
  conf.gem mgem: 'mruby-simpletest'
  conf.gem mgem: 'mruby-http'
  conf.gem mgem: 'mruby-json'
  conf.gem mgem: 'mruby-io'
  conf.gem mgem: 'mruby-socket'
  conf.gem mgem: 'mruby-pack'
  conf.gem mgem: 'mruby-env'

  # include the default GEMs
  conf.gembox 'full-core'
end
