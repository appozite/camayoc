$LOAD_PATH.unshift './lib'
require 'camayoc/version'

Gem::Specification.new do |s|
  s.name              = "camayoc"
  s.version           = Camayoc::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Camayoc makes it easy to send stats anywhere. "
  s.homepage          = "http://github.com/appozite/camayoc"
  s.email             = "hayes@appozite.com"
  s.authors           = [ "Hayes Davis" ]
  
  s.files            += Dir.glob("lib/**/*")

  #s.extra_rdoc_files  = [ "LICENSE", "README.md" ]

  s.description = <<-description
    Inspired by logging frameworks, Camayoc makes it easy send stats and metrics 
    from your application to collectors like Graphite (via statsd) or Redis. 
    Extensible handlers mean you can use whatever storage system you like 
    with the same interface.
  description
end
