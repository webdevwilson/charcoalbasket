$: << File.dirname( __FILE__ ) << File.join( File.dirname( __FILE__ ), 'lib' )

require 'rubygems'
require 'pony'
require 'erb'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader'
require 'calculator'
require 'json'

TESTING = false

if TESTING
  CHECKOUT_URL = 'https://sandbox.google.com/checkout/api/checkout/v2/checkoutForm/Merchant/120471905698092'
  CHECKOUT_BUTTON = 'https://sandbox.google.com/checkout/buttons/buy.gif?merchant_id=120471905698092&amp;w=117&amp;h=48&amp;style=white&amp;variant=text&amp;loc=en_US'
else
  CHECKOUT_URL = 'https://checkout.google.com/api/checkout/v2/checkoutForm/Merchant/835246094689493'
  CHECKOUT_BUTTON = 'http://checkout.google.com/buttons/checkout.gif?merchant_id=835246094689493&w=180&h=46&style=white&variant=text&loc=en_US'
end

MAIL_CONFIG = {}

def send_mail(email)
  Pony.mail( email.merge(MAIL_CONFIG) )
end

set :public, File.join( File.dirname(__FILE__), 'public' )
set :views, File.join( File.dirname(__FILE__), 'views' )

get '/' do
  redirect '/page/home'
end

get '/page/purchase/*/*' do
  erb "page/purchase".to_sym
end

get '/page/:page' do
  erb "page/#{params[:page]}".to_sym
end

get '/calculate.json' do
  content_type 'application/json'
  Calculator.calculate( params['s'], params['t'] ).to_json
end

post '/forms/feedback' do
  params[:to] = Configuration.feedback['to']
  params[:subject] = Configuration.feedback['subject']
  params[:body] = <<EOF
	Contact Us Form Received:

Name: #{params[:name]}
Email Address: #{params[:from]}
Comments:

#{params[:comments]}
EOF
  send_mail( params )
  redirect "/page/feedback-received"
end