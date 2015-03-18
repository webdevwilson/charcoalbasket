$: << File.dirname( __FILE__ ) << File.join( File.dirname( __FILE__ ), 'lib' )

require 'rubygems'
require 'pony'
require 'erb'
require 'sinatra'
require 'sinatra/content_for'
require 'calculator'
require 'json'

Configuration.environment = 'prod' # $*[0] || 'prod'
puts "Starting charcoalbasket.com #{Configuration.environment} site..."

Pony.options = {
  :via => :smtp,
  :via_options => {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => 'heroku.com',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
}

def send_mail(email)
  begin
    Pony.mail( email.merge(MAIL_CONFIG) )
  rescue Exception => e
    logger.error "Error sending email #{email} #{e}"
  end
end

set :public_folder, File.join( File.dirname(__FILE__), 'public' )
VIEWS = File.join( File.dirname(__FILE__), 'views' )
set :views, VIEWS

get '/public/*' do
  cache_length = 60 * 60 * 24
  cache_control :public, :max_age => cache_length
  'this is public'
end

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
    @name = 'Standard Charcoal Basket'
  elsif @type == 'brand'
    @brand = Configuration['brands'].select { |it| it['stub'] == params[:splat][1] }.first
    @spec = @brand['size'] || Configuration['default_size']
    @name = "Charcoal Basket for #{@brand['name']}"
  elsif @type == 'custom'
    @shape = params[:splat][1]
    if( @shape.eql? 'round' )
      @spec = 'round:18x6'
      @name = 'Custom Charcoal Basket (Round)'
    else
      @spec = 'square:12x12x6'
      @name = 'Custom Charcoal Basket (Square)'
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

post '/purchase/by_mail.html' do
  erb 'page/by_mail'.to_sym
end

post '/purchase/by_mail_print.html' do
  body =
  send_mail({
    :subject => 'charcoalbasket.com mail order in flight',
    :to      => Configuration['feedback']['to'],
    :from    => 'no-reply@charcoalbasket.com',
    :body    => params.collect { |k,v| "#{k} = #{v}\n" }
  })
  erb 'page/by_mail_print'.to_sym
end

post '/forms/feedback.html' do
  params[:subject] = 'charcoalbasket.com feedback'
  params[:to] = Configuration['feedback']['to']
  params[:subject] = Configuration['feedback']['subject']
  params[:from] = params[:email_address]
  params[:body] = <<EOF
Name: #{params[:name]}
Email Address: #{params[:email_address]}
Comments:

#{params[:comments]}
EOF
  params.delete "name"
  params.delete "email_address"
  send_mail( params )
  redirect "/page/feedback-received"
end
