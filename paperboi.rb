require 'news-api'

class Paperboi
  def self.news
    top_headlines = api.get_top_headlines(q: 'covid',
                                              category: 'health',
                                              language: 'en',
                                              country: 'us')

    top_headlines.filter { _1.title.match?("death") }.collect { "<a href='#{_1.url}'>#{_1.title}</a>"}.join("\n")
  end

  def self.api
    @newsapi ||= News.new(ENV["NEWS_API_KEY"])
  end
end

