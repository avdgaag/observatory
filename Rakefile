require 'bundler'
Bundler::GemHelper.install_tasks
Bundler.require(:default, :development)
require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'app/**/*.rb', '-', 'LICENSE', 'HISTORY']
  t.options = %w{--title Observatory -m markdown}
end
