# CfCanaries

[![Build Status](https://travis-ci.org/pivotal-cf-experimental/cf_canaries.png)](https://travis-ci.org/pivotal-cf-experimental/cf_canaries)

Install canary apps into a Cloudfoundry cluster.

## Installation

Install the cf_canaries cli by running these commands:

    $ bundle
    $ gem build cf_canaries.gemspec
    $ gem install cf_canaries-0.1.0.gem

## Usage

    $ canaries --number-of-zero-downtime-apps=0 \
               --number-of-instances-canary-instances=0 \
               --app-domain=<Application Domain> \
               --target=<Cloudfoundry API Endpoint> \
               --username=<Cloudfoundry Username> \
               --password=<Cloudfoundry Password> \
               --organization=<Cloudfoundry Organization> \
               --space=<Cloudfoundry Space>

If SSL in not enabled you can also specify the `--skip-ssl-validation` flag.


### Optional command-line flags

- `--dry-run`: If set, shows all the commands the canary breeder will run without actually executing them
- `--number-of-instances-per-app=<n>`: Push n instances of each app (apart from the instances canaries). Defaults to 1.

## Canaries

The different types of canaries all correlate to different metrics that we want to be aware of.  Each canary's purpose is documented below.

### Aviary Canary

This canary can be found at `aviary.<app-domain>`.  It is meant to aggregate response information from the zero-downtime-canary and instances-canary applications.

`/instances_aviary` will respond with a 200 if the `/instances_pinged_aviary` and `/instances_from_cf_aviary` checks succeed.

`/instances_pinged_aviary` will send (4 * # of instances) requests to the instances canary. It will return a 200 if 80% or more of instances respond.

`/instances_from_cf_aviary` will check on the number of running instances for the instances canary app using the CFoundry::Client library. It will return a 200 if 80% or more of the instances are reporting as running.

`/zero_downtime_aviary` will check all of the zero-downtime-canaries and will respond with a 200 if all are responding.

`/instances_heartbeats/:index` is the endpoint which the instances canary will hit in order to register a heart beat.

`/instances_heartbeats` will return a 200 if all instances of the instances canary have heartbeated within 15 seconds. 

### Long Running Canary

This canary can be found at `long-running-canary.<app-domain>`.

It will return "Hello, World!" when you make an http request to its root `/`.

### Zero Downtime Canary

This canary can be found at `zero-downtime-canary<index>.<app-domain>`.

This canary is meant to be pushed with multiple instances, specified with the `--number-of-zero-downtime-apps` flag.

It returns "Zero downtime canary sings" when you make an http request to its root `/`.

If you have more than one instance and more than one DEA in your deployment this app should always respond.

### CPU Canary

This canary can be found at `cpu.<app-domain>`.

This canary is meant to constantly be using a certain percentage of CPU.

It will return "Sing" when you make an http request to its root `/`.

### Disk Canary

This canary can be found at `disk.<app-domain>`.

This canary creates a file of size SPACE on disk inside its container.

It will return "Sing" when you make an http request to its root `/`.

### Memory Canary

This canary can be found at `memory.<app-domain>`.

This canary will increase memory usage to MEMORY. 

It will return "Sing" when you make an http request to its root `/`.

### Network Canary

This canary can be found at `network.<app-domain>`.

This canary will attempt to contact www.google.com when you make an http request to its root `/`.

It will return "Canary croaked" if it fails to reach www.google.com.

It will return "Canary sings" if it succeeds to reach www.google.com.

### Instances Canary

This canary can be found at `instances-canary.<app-domain>`.

It will return "Hello Canary Tweet Tweet Chirp Chirp!" when you make an http request to its root `/`.

It will return the instance index of the responding instance when you make an http request to `/instance-index`.

All of the instances will heartbeat to the Aviary canary every 10 seconds.

The Aviary will keep track of whether or not instances are heartbeating.

## Contributing

1. Fork it ( http://github.com/pivotal-cf-experimental/cf_canaries/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
