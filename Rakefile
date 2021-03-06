require 'bundler'
begin
  Bundler.setup
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rake/clean'

$:.unshift(File.join(File.dirname(__FILE__), './lib'))

require 'anystyle/version'

task :default
task :build => [:clean] do
  system 'gem build anystyle-parser.gemspec'
end

task :release => [:build] do
  system "git tag #{AnyStyle::VERSION}"
  system "gem push anystyle-parser-#{AnyStyle::VERSION}.gem"
end

task :check_warnings do
  $VERBOSE = true
  require 'anystyle/parser'

  puts AnyStyle::VERSION
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

begin
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  task :test_with_coveralls => [:spec, 'coveralls:push']
rescue LoadError
  # ignore
end if ENV['CI']

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  # ignore
end

desc 'Run an IRB session with AnyStyle loaded'
task :console, [:script] do |t, args|
  ARGV.clear
  require 'irb'
  require 'anystyle'
  IRB.conf[:SCRIPT] = args.script
  IRB.start
end

desc 'Update model using latest source and training data'
task :train, :threads do |t, args|
  require 'anystyle'
  Wapiti.debug!
  AnyStyle::Parser.defaults[:threads] = (args[:threads] || 4).to_i
  AnyStyle.parser.train
  AnyStyle.parser.model.save
end

desc 'Check all tagged datasets'
task :check do
  require 'anystyle'
  Dir['./res/parser/*.xml'].each do |xml|
    print 'Checking %.15s' % "#{File.basename(xml)}............"
    start = Time.now
    stats = AnyStyle.parser.check xml.untaint
    time = Time.now - start
    if stats[:token][:errors] == 0
      puts '   ✓                               %2ds' % time
    else
      puts '%4d seq %6.2f%% %6d tok %5.2f%% %2ds' % [
        stats[:sequence][:errors],
        stats[:sequence][:rate],
        stats[:token][:errors],
        stats[:token][:rate],
        time
      ]
    end
  end
end

desc "Save delta of a tagged dataset with itself"
task :delta, :xml do |t, args|
  require 'anystyle'
  print 'Checking %.15s' % "#{File.basename(args[:xml])}............"
  input = Wapiti::Dataset.open args[:xml].untaint
  output = AnyStyle.parser.label input
  delta = output - input
  if delta.length == 0
    puts ' ✓'
  else
    name = File.basename(args[:xml], '.xml')
    delta.save "#{name}.delta.xml", indent: 2
    puts "delta saved to #{name}.delta.xml (#{delta.length})"
  end
end

CLEAN.include('*.gem')
CLEAN.include('*.rbc')
