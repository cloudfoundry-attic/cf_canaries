# CfCanaries

[![Build Status](https://travis-ci.org/pivotal-cf-experimental/cf_canaries.png)](https://travis-ci.org/pivotal-cf-experimental/cf_canaries)

Install canary apps into a Cloudfoundry cluster.

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
               --target=<Cloudfoundry API Endpoint> \
               --username=<Cloudfoundry Username> \
               --password=<Cloudfoundry Password> \
               --organization=<Cloudfoundry Organization> \
               --space=<Cloudfoundry Space>


### Optional command-line flags

- `--dry-run`: If set, shows all the commands the canary breeder will run without actually executing them
- `--number-of-instances-per-app=<n>`: Push n instances of each app (apart from the instances canaries). Defaults to 1.


## Contributing

1. Fork it ( http://github.com/pivotal-cf-experimental/cf_canaries/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
