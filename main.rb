$: << File.dirname( __FILE__ ) << File.join( File.dirname( __FILE__ ), 'lib' )

require 'rubygems'
require 'pony'
require 'erb'
require 'sinatra'
require 'sinatra/content_for'
#require 'sinatra/reloader'
require 'calculator'
require 'json'

Configuration.environment = 'prod' # ( defined?($*) ? $*[0] : nil ) || 'prod'
puts "Starting charcoalbasket.com #{Configuration.environment} site..."

MAIL_CONFIG = {}

def send_mail(email)
  Pony.mail( email.merge(MAIL_CONFIG) )
end

set :public_folder, File.join( File.dirname(__FILE__), 'public' )
VIEWS = File.join( File.dirname(__FILE__), 'views' )
set :views, VIEWS

not_found do
  erb 'errors/page-not-found'.to_sym
end

error do
  erb 'errors/internal-error'.to_sym
end

get '/' do
  redirect '/page/home'
end

get '/purchase/*/*.html' do
  @type = params[:splat][0]
  if @type == 'standard'
    @spec = 'square:12x12x6'
  elsif @type == 'brand'
    @brand = Configuration['brands'].select { |it| it['stub'] == params[:splat][1] }.first
    @spec = @brand['size'] || Configuration['default_size']
  elsif @type == 'custom'
    @shape = params[:splat][1]
    if( @shape.eql? 'round' )
      @spec = 'round:18x6'
    else
      @spec = 'square:12x12x6'
    end
  end
  @product_info = Calculator.calculate(@spec)
  erb "page/purchase".to_sym
end

get '/forms/:page' do
  if params[:page] == 'send'
    raise Sinatra::NotFound.new
  end
end

get '/page/:page' do
  if /\.html/ =~ params[:page]
    file_path = "page/#{params[:page][0..-6]}"
    if File.exists?( File.join( VIEWS, file_path ) + ".erb" )
      erb file_path.to_sym
    else
      raise Sinatra::NotFound.new
    end
  else
    
    if params[:page] == 'purchase'
      redirect_url = '/purchase/standard/size.html'
    elsif params[:page] == 'grills'
      raise Sinatra::NotFound.new
    else
      redirect_url = "/page/#{params[:page]}.html"
    end
    
    redirect redirect_url, 301
    
  end
end

get '/*.json' do
  content_type 'application/json'
  op=params[:splat][0]
  Calculator.calculate( params['s'] ).to_json
end

post '/forms/feedback.html' do
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