require 'sinatra/base'
require 'twitter'

CONSUMER_KEY        = ENV['CONSUMER_KEY']
CONSUMER_SECRET     = ENV['CONSUMER_SECRET']
ACCESS_TOKEN        = ENV['ACCESS_TOKEN']
ACCESS_TOKEN_SECRET = ENV['ACCESS_TOKEN_SECRET']

LOGIN_CONSUMER_KEY    = ENV['LOGIN_CONSUMER_KEY'] || CONSUMER_KEY
LOGIN_CONSUMER_SECRET = ENV['LOGIN_CONSUMER_SECRET'] || CONSUMER_SECRET

module UpdateName
  class Server < Sinatra::Base
    configure do
      set :sessions, true
    end

    use OmniAuth::Builder do
      provider :twitter, LOGIN_CONSUMER_KEY, LOGIN_CONSUMER_SECRET
    end

    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }

    get '/' do
      'hello'
    end
  end
end
