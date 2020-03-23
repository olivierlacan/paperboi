require 'news-api'
require 'date'

class Paperboi
  def self.news(query, state)
    request_query = build_request(query, state)

    cache_key = "#{Digest::SHA1.base64digest(request_query.to_json)}"

    stored_response = check_cache(cache_key)

    if stored_response
      stored_response
    else
      api_response = api.get_everything(**request_query)

      if api_response.empty?
        puts "No results for #{request_query.inspect}"
      else
        puts "Results found for #{request_query.inspect}"
      end

      write_cache(cache_key, api_response)

      check_cache(cache_key)
    end
  end

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

  def self.check_cache(key)
    payload = cache.get(key)

    if payload
      puts "cache hit for #{key}"
      JSON.parse(payload)
    else
      puts "cache miss for #{key}"
    end
  end

  def self.write_cache(key, value)
    puts "cache write for #{key}"
    payload = serialize(value)
    puts "caching serialized payload: #{payload.inspect}"

    cache.multi do
      cache.set(key, payload)
      cache.get(key)
    end
  end

  def self.serialize(value)
    value.map do
      {
        title: _1.title,
        content: _1.content,
        published_at: _1.publishedAt,
        url: _1.url,
        description: _1.description
      }
    end.to_json
  end

  def self.production?
    ENV["RACK_ENV"] == "production"
  end

  def self.development?
    !production?
  end

  def self.cache
    @redis ||= if production?
      Redis.new(url: ENV["REDIS_URL"])
    else
      Redis.new
    end
  end
end

