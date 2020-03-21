require 'rubygems'
require 'bundler'

Bundler.setup

if ENV["RACK_ENV"] != "production"
  require 'dotenv'
  Dotenv.load
end

require "./paperboi"

run lambda { |env|
  [
    200,
    {'Content-Type'=>'text/html'},
    formatted_payload
    ]
}

def payload
  query = 'covid AND death'
  results = Paperboi.news(query)

  <<~HTML
  <!DOCTYPE html>
  <html>
  <head>
    <title>Paperboi</title>
    <meta charset="UTF-8">
  </head>
  <body>
    <h1>Paperboi</h1>
    <p>Returning you all health-related news articles matching #{query}</p>
    <ul>
      #{results}
    </ul>
  </body>
  </html>
  HTML
end

def formatted_payload
  StringIO.new(payload)
end
