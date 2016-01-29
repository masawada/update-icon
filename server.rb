require 'sinatra/base'
require 'sinatra/flash'
require 'omniauth'
require 'omniauth-twitter'
require 'twitter'

if ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

CONSUMER_KEY        = ENV['CONSUMER_KEY']
CONSUMER_SECRET     = ENV['CONSUMER_SECRET']
ACCESS_TOKEN        = ENV['ACCESS_TOKEN']
ACCESS_TOKEN_SECRET = ENV['ACCESS_TOKEN_SECRET']

LOGIN_CONSUMER_KEY    = ENV['LOGIN_CONSUMER_KEY'] || CONSUMER_KEY
LOGIN_CONSUMER_SECRET = ENV['LOGIN_CONSUMER_SECRET'] || CONSUMER_SECRET

SCREEN_NAME  = ENV['SCREEN_NAME']
BANNED_USERS = ENV['BANNED_USERS']

CLIENT = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end

module UpdateName
  class Server < Sinatra::Base
    configure do
      register Sinatra::Flash
      set :sessions, true
    end

    helpers do
      def authenticate(auth)
        return false unless auth['uid'] && auth['provider']

        if BANNED_USERS.split(',').include? auth['info']['nickname']
          flash[:error] = "許可されていないユーザです"
          redirect '/'
        end

        session[:user_id] = auth['uid']
        session[:screen_name] = auth['info']['nickname']
        session[:icon_path] = auth['extra']['raw_info']['profile_image_url_https']
        true
      end

      def signed_in?
        user = current_user
        user.nil? == false
      end

      def require_signin
        unless signed_in?
          flash[:error] = "ログインが必要です"
          redirect '/'
        end
      end

      def sign_out
        session[:user_id] = nil
        session[:screen_name] = nil
        session[:icon_path] = nil
      end

      def current_user
        user_id = session[:user_id]
        screen_name = session[:screen_name]
        icon_path = session[:icon_path]
        return nil if user_id.nil?

        {
          user_id: user_id,
          screen_name: screen_name,
          icon_path: icon_path
        }
      end
    end

    use OmniAuth::Builder do
      provider :twitter, LOGIN_CONSUMER_KEY, LOGIN_CONSUMER_SECRET
    end

    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }

    before do
      @target_screen_name = SCREEN_NAME

      if signed_in?
        @user = current_user
        @client = Twitter::REST::Client.new do |config|
          config.consumer_key        = CONSUMER_KEY
          config.consumer_secret     = CONSUMER_SECRET
          config.access_token        = ACCESS_TOKEN
          config.access_token_secret = ACCESS_TOKEN_SECRET
        end
      end
    end

    get '/' do
      if signed_in?
        erb :index
      else
        erb :signin
      end
    end

    # auth
    get '/auth/twitter/callback' do
      if authenticate(request.env['omniauth.auth'])
        # TODO: flash sign in successfully
        flash[:info] = "ログインしました"
      else
        flash[:error] = "ログインに失敗しました"
      end

      redirect '/'
    end

    get '/auth/failure' do
      flash[:error] = "ログインに失敗しました"
      redirect '/'
    end

    get '/logout' do
      sign_out
      flash[:info] = "ログアウトしました"
      redirect '/'
    end

    post '/upload' do
      begin
        @client.update_profile_image(params[:file][:tempfile])
        @client.update("@#{@user[:screen_name]} アイコンを変更しました。ご提供ありがとうございます。")
        flash[:info] = "アイコンを変更しました (<a href=\"https://twitter.com/#{@target_screen_name}\">アイコンを見る</a>)"
      rescue
        flash[:error] = "アイコンの変更に失敗しました"
      end

      redirect '/'
    end
  end
end
