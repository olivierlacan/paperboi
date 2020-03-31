require "news-api"
require "date"

class Paperboi
  def self.search
    result_template(
      news_query,
      Date.today.prev_day(3).iso8601,
      Date.today.iso8601
    )
  end

  def self.prison
    result_template(
      prison_query,
      Date.today.prev_day(7).iso8601,
      Date.today.iso8601
    )
  end

  def self.news_query
    "(covid OR coronavirus OR covid-19) AND (death OR positive OR negative OR confirmed OR hospitalized OR pending)"
  end

  def self.prison_query
    "prison AND (covid OR coronavirus OR covid-19)"
  end

  def self.result_template(query, from_date, to_date)
    <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>paperboi</title>
    </head>
    <body>
      <h1>paperboi</h1>
      <p>
        Returning all news articles matching <strong>#{query}</strong> for all
        states sorted by relevancy and limited to one per state between
        #{from_date} and #{to_date}.
      </p>
      <ul>
        #{results_for_all_states(query, from_date, to_date)}
      </ul>
    </body>
    </html>
    HTML
  end

  def self.results_for_all_states(query, from_date, to_date)
    states.map do |abbreviation, state|
      <<~HTML
        <ul>
          <li>#{state}</li>
          <ul>
            #{items(query, state, from_date, to_date)}
          </ul>
        </ul>
      HTML
    end.join("\n")
  end

  def self.items(query, state, from_date, to_date)
    articles = Paperboi.news(query, state, from_date, to_date)

    return "<li>No results</li>" if articles.empty?

    articles.collect do
      <<~HTML
        <li>
          <a href="#{_1["url"]}">#{_1["title"]}</a> #{t(_1["published_at"])}
        </li>
      HTML
    end.join("\n")

  rescue TooManyRequestsException => error
    puts error.message

    <<~HTML
      <li>
        NewsAPI rate limit reached.
      </li>
    HTML
  end

  def self.t(datetime)
    DateTime.parse(datetime).new_offset("-0500").strftime("%-m/%-d %k:%M")
  end

  def self.states
    [
      ["AK", "Alaska"],
      ["AL", "Alabama"],
      ["AR", "Arkansas"],
      ["AS", "American Samoa"],
      ["AZ", "Arizona"],
      ["CA", "California"],
      ["CO", "Colorado"],
      ["CT", "Connecticut"],
      ["DC", "District of Columbia"],
      ["DE", "Delaware"],
      ["FL", "Florida"],
      ["GA", "Georgia"],
      ["GU", "Guam"],
      ["HI", "Hawaii"],
      ["IA", "Iowa"],
      ["ID", "Idaho"],
      ["IL", "Illinois"],
      ["IN", "Indiana"],
      ["KS", "Kansas"],
      ["KY", "Kentucky"],
      ["LA", "Louisiana"],
      ["MA", "Massachusetts"],
      ["MD", "Maryland"],
      ["ME", "Maine"],
      ["MI", "Michigan"],
      ["MN", "Minnesota"],
      ["MO", "Missouri"],
      ["MS", "Mississippi"],
      ["MT", "Montana"],
      ["NC", "North Carolina"],
      ["ND", "North Dakota"],
      ["NE", "Nebraska"],
      ["NH", "New Hampshire"],
      ["NJ", "New Jersey"],
      ["NM", "New Mexico"],
      ["NV", "Nevada"],
      ["NY", "New York"],
      ["OH", "Ohio"],
      ["OK", "Oklahoma"],
      ["OR", "Oregon"],
      ["PA", "Pennsylvania"],
      ["PR", "Puerto Rico"],
      ["RI", "Rhode Island"],
      ["SC", "South Carolina"],
      ["SD", "South Dakota"],
      ["TN", "Tennessee"],
      ["TX", "Texas"],
      ["UT", "Utah"],
      ["VA", "Virginia"],
      ["VI", "Virgin Islands"],
      ["VT", "Vermont"],
      ["WA", "Washington"],
      ["WI", "Wisconsin"],
      ["WV", "West Virginia"],
      ["WY", "Wyoming"]
    ]
  end

  def self.news(query, state, from_date, to_date)
    request_query = build_request(query, state, from_date, to_date)

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
  rescue UnauthorizedException => error
    raise "#{error}: missing NEWS_API_KEY environment variable"
  end

  def self.build_request(query, state, from_date, to_date)
    {
      qInTitle: "#{state} AND #{query}",
      from: from_date, to: to_date,
      language: "en", sortBy: "relevancy", pageSize: 1
    }
  end

  def self.api
    @newsapi ||= News.new(ENV["NEWS_API_KEY"])
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

