require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require "yard"

yard_files = ['lib/**/*.rb','-','LICENSE.md']
yard_opts  = [ 
    '--markup', 'markdown',
    '--markup-provider', 'redcarpet',
    '--readme', 'README.md',
    '--no-private',
    '--exclude', 'lib/*/cli.rb'
]

YARD::Rake::YardocTask.new do |t|
  t.files   = yard_files
  t.options = yard_opts
end
task :yard_server => [:yard] do
  system "yard server --reload"
end
begin
  require 'ci/reporter/rake/rspec'
rescue LoadError
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/unit/**/*_spec.rb"
end

task :default do
  sh %{rake -T}
end