require 'rubygems'
require 'bundler'

Bundler.require

require "./paperboi"

if Paperboi.development?
  require 'dotenv'
  Dotenv.load
end

run lambda { |env|
  [
    200,
    {'Content-Type'=>'text/html'},
    formatted_payload
    ]
}

def payload
  query = '(covid OR coronavirus OR covid-19) AND (death OR positive OR confirmed)'

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
      #{Paperboi.from_date} and #{Paperboi.to_date}.
    </p>
    <ul>
      #{results_for_all_states(query)}
    </ul>
  </body>
  </html>
  HTML
end

def results_for_all_states(query)
  states.map do |abbreviation, state|
    <<~HTML
      <ul>
        <li>#{state}</li>
        <ul>
          #{items(query, state)}
        </ul>
      </ul>
    HTML
  end.join("\n")
end

def items(query, state)
  items = Paperboi.news(query, state).collect do
    <<~HTML
      <li>
        <a href='#{_1["url"]}'>#{_1["title"]}</a> #{_1["published_at"]}
      </li>
    HTML
  end.join("\n")
end

def formatted_payload
  StringIO.new(payload)
end

def states
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
