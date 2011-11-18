$LOAD_PATH.unshift './lib'
require 'camayoc/version'

Gem::Specification.new do |s|
  s.name              = "camayoc"
  s.version           = Camayoc::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Camayoc makes it easy to send stats anywhere. "
  s.homepage          = "http://github.com/appozite/camayoc"
  s.email             = "hayes@appozite.com"
  s.authors           = [ "Hayes Davis", "Jerry Chen" ]
  
  s.files             += %w(README.md LICENSE)
  s.files             += Dir.glob("lib/**/*")
  s.files             += Dir.glob("test/**/*")

  s.extra_rdoc_files  = [ "LICENSE", "README.md", "HISTORY.md" ]

  s.add_development_dependency("mocha")

  s.description = <<-description
    Inspired by logging frameworks, Camayoc makes it easy to track events and 
    send stats from your application to collectors like Graphite (via statsd). 
    It has an extensible handler system that allows you to use whatever storage 
    system you like with the same interface.
  description
end