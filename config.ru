require 'rubygems'
require 'bundler'

Bundler.setup

if !ENV["RACK_ENV"] == "production"
  require 'dotenv'
  Dotenv.load
end

require "./paperboi"

run lambda { |env|
  [
    200,
    {'Content-Type'=>'text/html'},
    StringIO.new(Paperboi.news)]
}
