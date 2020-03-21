# paperboi

![Lewis Wickes Hine for the National Child Labor Commission, 1915](https://p198.p4.n0.cdn.getcloudapp.com/items/5zuyb5LQ/esYSqmj.jpg?v=431b9e6e63c191f99f1ca55f5f7a42f7)
> always 'bout that paper, boy

Using NewsAPI, paperboi fetches very specific COVID-19 related news article and
returns them neatly organized by state or U.S. territory with the title of the
article, a link to it, and the publication date.

Results are cached to avoid reaching the daily 500 request limit from NewsAPI.
The entire constructed hash body of each state-specific query is digested with
`Digest::SHA1.base64digest` to create a fairly compact but unique and repeatable
key for Redis, then a request is made to NewsAPI, and only relevant news article
data is serialized into a JSON object containing: `title`, `content`, `url`,
`publishedAt`. There is no cache eviction strategy but the cache will
automatically expire after the end of the EDT/EST timezone day since all
NewsAPI queries are scoped a 3-day window starting today and going back 3 days.

## System Requirements

- Redis (no password, `127.0.0.1:6379`)
- Ruby (see `.ruby_version`)

## Installation

- `bundle install`

## Development

- `bundle rerun`

Don't worry about deprecation warnings, this is an old library but it does the trick.

## Production

- `rackup`
