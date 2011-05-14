require 'rubygems'

# add vender gems to the load path
$: << Dir.glob( File.join( 'vendor', 'gems', '*', 'lib' ) )
$:.flatten!

require 'sinatra'
require 'main.rb'

root_dir = File.dirname(__FILE__)

set :environment, :production
set :app_file, File.join( root_dir, 'main.rb' )
disable :run

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new( File.join( root_dir, 'log', 'sinatra.log' ), 'a')
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application