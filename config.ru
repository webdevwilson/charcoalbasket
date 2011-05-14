require 'rubygems'
$: << Dir.glob( File.join( 'vendor', 'gems', '*', 'lib' ) )
$:.flatten!

require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'main.rb'
run Sinatra.application