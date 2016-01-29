require 'sinatra/base'
require 'twitter'

module UpdateName
  class Server < Sinatra::Base
    get '/' do
      'hello'
    end
  end
end
