require 'news-api'
require 'date'

class Paperboi
  def self.news(query, state)
    request_query = build_request(query, state)

  def self.build_request(query, state)
    {
      qInTitle: "#{query} AND #{state}",
      from: from_date, to: to_date,
      language: 'en', sortBy: 'relevancy', pageSize: 1
    }
  end

  def self.api
    @newsapi ||= News.new(ENV["NEWS_API_KEY"])
  end

  def self.from_date
    Date.today.prev_day(3).iso8601
  end

  def self.to_date
    Date.today.iso8601
  end
  def self.production?
    ENV["RACK_ENV"] == "production"
  end

  def self.development?
    !production?
  end
end

