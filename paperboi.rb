require 'rubygems'
require 'bundler'

Bundler.setup

require 'dotenv'
Dotenv.load

require 'news-api'

# Init
newsapi = News.new(ENV["NEWS_API_KEY"])

# /v2/top-headlines
top_headlines = newsapi.get_top_headlines(q: 'covid',
                                          category: 'health',
                                          language: 'en',
                                          country: 'us')

puts top_headlines.filter { _1.title.match?("death") }.collect(&:title)


