desc 'Deletes all generated output files.'
task :clean do
  sh 'rm -rf app/js'
  sh 'rm -rf app/css'
  sh 'rm -rf public'
  puts 'Deleted generated output files.'
end

desc 'Deletes all cached files.'
task reset: [:clean] do
  sh 'rm -rf bower_components'
  sh 'rm -rf .sass-cache'
  puts 'Deleted all cached files.'
end

file 'bower_components' do
  puts 'Make sure you have NPM installed.'
  puts 'Installing JavaScript dependencies...'
  sh 'bower install'
end

desc 'Installs JavaScript dependencies.'
task install: ['bower_components'] do
  puts 'JavaScript dependencies installed.'
end

desc 'Reinstalls Javascript dependencies.'
task reinstall: [:reset, :install]

task guard: ['bower_components'] do
  puts 'Starting guard...'
  system 'bundle exec guard --no-interactions'
end

task sinatra: ['bower_components'] do
  puts 'Starting server...'
  system 'ruby server.rb'
end

desc 'Runs the sinatra server and guard for local testing.'
multitask server: [:guard, :sinatra]

desc 'Defaults to rake server.'
task default: [:server]
task s: [:server]
