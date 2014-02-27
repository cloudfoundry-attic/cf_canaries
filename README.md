# CfCanaries

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'cf_canaries'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cf_canaries

## Usage

    $ canaries --number-of-zero-downtime-apps=0 \
               --number-of-instances-canary-instances=0 \
               --app-domain=<Application Domain> \
               --canaries-path=<path/to/vcap-test-assets/canaries> \
               --target=<Cloudfoundry API Endpoint> \
               --username=<Cloudfoundry Username> \
               --password=<Cloudfoundry Password>

## Contributing

1. Fork it ( http://github.com/pivotal-cf-experimental/cf_canaries/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
