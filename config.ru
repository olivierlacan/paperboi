require 'rubygems'
require 'bundler'

Bundler.setup

require 'dotenv'
Dotenv.load

require "./lib/paperboi"

run lambda { |env|
  [
    200,
    {'Content-Type'=>'text/html'},
    StringIO.new(Paperboi.news)]
}
