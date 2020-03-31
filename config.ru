require "rubygems"
require "bundler"

Bundler.require

require "date"
require "./paperboi"

if Paperboi.development?
  require "dotenv"
  Dotenv.load
else
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]
  end

  use Bugsnag::Rack
end

app = Hanami::Router.new do
  get "/", to: ->(env) { [200, {"Content-Type"=>"text/html"}, StringIO.new(Paperboi.search)] }
  get "/prison", to: ->(env) { [200, {"Content-Type"=>"text/html"}, StringIO.new(Paperboi.search)] }
end

run app
