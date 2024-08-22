# Forecaster

`Forecaster` is a browser based application to display the current temperature in Fahrenheit; the expected high low for
the day, and an advanced forecast -- houry expected temps for the next 24 hours; daily high/low for the next week for a
given US address.

## Scope

1. Use Ruby On Rails.

2. Accept an address as input.

3. Retrieve forecast data for the given address. This should include, at minimum, the current temperature. Bonus points: retrieve high/low and/or extended forecast.

4. Display the requested forecast details to the user.

5. Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.

## Setup

This was developed on MacOS Sonoma 14.5 using `rbenv` as a ruby version manager. Some of the steps may be different for
you.

* Install and start Postgres. I used v 15 but the project doesn't depend on any special features of Postgres. Most
  recent versions will work.
* Install ruby v 3.2.2
* Install `bundler`
```shell
gem install bundler
```
* Download the code from GitHub
* Install dependencies
```shell
bundle install
```
* Initialize the Postgres DB
```shell
rails db:create db:migrate
```

* run tests to double check installation
```shell
bundle exec rspec spec
```
* start the rails server
```shell
./bin/dev
```
* Open `localhost:3000` in the browser of your choice.

## Documentation
This project uses `yard` for documentation.

Install `yard` with:
```shell
gem install yard
```

Compile the documentation locally with:
```shell
yard doc
```

Start the `yard` server with:
```shell
yard server
```

View the documentation by opening a browser of your choice and directing it to:
`localhost:8808`

## Meteorological Data using OpenMeteo
The primary factor behind selecting OpenMeteo as a meteorological data vendor: the service doesn't require an account or a key.

While I don't want evaluators to have to create an account or configure the system with an API key just to evaluate this 
exercise, OpenMeteo API requires a location in longitude & latitude, forcing geolocation of the address in an additional 
call to a geolocation service.

OpenMeteo is also limited to 10,000 calls per day.

A production system should (probably) have a paid primary source for meteorological data with a SLA and BA agreement, 
a back up source in case the primary is unavailable, system notification of outages, automated switch over, and an 
adapter to manage differences between the two data sources.

Documentation can be found here: https://open-meteo.com

## Geocoding Using Census.gov Geocoder

For the purposes of this exercise, I wanted to use a geocoding service that didn't require the user to create an account
or configure API keys. The Census.gove geocoding service is free, has no use limits, and doesn't require an account or 
API key.

Census.gov is not ideal for a production system -- it's slow, there's SLA, and no BA agreement. It may or may not be 
HIPPA or GDPR compliant. I can't find an SLA. Presumably they won't sign a BA.

Documentation can be found here: https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html#_Toc163649717

## Design Patterns
* CensusGovLocationService is a factory, returning a Location
* OpenMeteoForecastService is a factory, returning a Forecast

## Recommendations and Suggestions

* Project UX dependent: make Street a required field via HTML attributes rather than relying on model validations.
* Project UX dependent: improve validation messages when city, state and zip are all blank to clarify the system needs
  zip, or city + state.
* Replace the calls to Census.gov geocoder and OpenMeteo services with a single API call.
* Add instrumentation on API calls to determine how long they tak.
* Add a log analysis tool to monitor how long it takes to complete API calls and raise an alert if they exceed typical
  performance parameters.
* Add a backup data source for API calls with automated switch over if the primary data source is unavailable longer
  than our SLA allows. Alert the engineers in the event of a switch over.
* Close the request, query the data source in an async job, and lazy update the results. I don't like having request 
  threads open while waiting on results of an API call.
* This implementation uses TurboStreams. With enough simultaneous connections, you might need an alternative. 
  AnyCable perhaps.
* Caching uses Rails memory cache which is cleared when the server is restarted. For production, a store like `redis`
  or `memcache` might be an improvement. 
