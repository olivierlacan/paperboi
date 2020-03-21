require 'news-api'

class Paperboi
  def self.news(query)
    top_headlines = api.get_top_headlines(q: query,
                                              category: 'health',
                                              language: 'en',
                                              country: 'us')

    top_headlines.collect { "<li><a href='#{_1.url}'>#{_1.title}</a></li>"}.join("\n")
  end

  def self.api
    @newsapi ||= News.new(ENV["NEWS_API_KEY"])
  end
  def self.production?
    ENV["RACK_ENV"] == "production"
  end

  def self.development?
    !production?
  end
end

