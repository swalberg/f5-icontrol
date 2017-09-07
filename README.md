# F5::Icontrol

[![Build Status](https://travis-ci.org/swalberg/f5-icontrol.svg?branch=master)](https://travis-ci.org/swalberg/f5-icontrol)

This is the F5-icontrol gem. If you have an F5, it can use the iControl API to automate things

This is not the official library. That one is [here](https://devcentral.f5.com/d/icontrol-ruby-library). This copy is without warranty. Heck, it probably doesn't even work.

I originally set out to improve the official one:

* Improve testing using rspec and vcr
* Convert to a supported SOAP parser, such as savon
* Support Ruby 2.0.0 and 2.1.0
* Make the interface to the library more Ruby-esque

But given the original one was pretty bare-bones, I started over. 

## Installation

Add this line to your application's Gemfile:

    gem 'f5-icontrol'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install f5-icontrol

## Usage (REST interface)

*NOTE:* The REST interface is still a work in progress! The conventions may change until we release.

First configure an instance of the API to point to your F5

```Ruby
require 'f5/icontrol'

f5 = F5::Icontrol::RAPI.new username: 'admin', password: 'admin', host: '10.1.1.1'
```

After that, the calls should line up directly to the [API Docs](https://devcentral.f5.com/wiki/iControlREST.APIRef.ashx). For collections, use the following methods:

| HTTP Verb | Method         |
|-----------|----------------|
| GET       | get_collection |

Note that `get_collection` is optional if you call `#each` or some `Enumberable` method. So `foo.get_collection.each` can be shortened to `foo.each`.

For resources

| HTTP Verb | Method         |
|-----------|----------------|
| GET       | load           |
| PUT       | update         |
| DELETE    | delete         |
| POST      | create         |


For example, to get all the pools:

```Ruby
pools = f5.mgmt.tm.ltm.pool.get_collection

puts pools.map(&:name)

# shorter method
puts f5.mgmt.tm.ltm.pool.map(&:name)
```

It'll also understand subresources:

```Ruby
members = pools.members.load
puts members.map(&:address)

```

Or, let's create a pool:

```Ruby
api.mgmt.tm.ltm.pool.create(name: 'seanstestrest')
```

## Usage (SOAP interface)

*Note* - SOAP will likely be deprecated prior to version 1.0 of this gem. The REST interface is more intuitive and dropping SOAP makes this gem so much lighter.

First, configure the gem:

```Ruby
F5::Icontrol.configure do |f|
  f.host = "hostname.of.bigip"
  f.username = "username"
  f.password = "password"
end
```

Then use it:

```Ruby
api = F5::Icontrol::API.new
response = api.LocalLB.Pool.get_list
```

or You can configure per api client.

```Ruby
api = F5::Icontrol::API.new(
    host: "hostname.of.bigip",
    username: "username",
    password: "password",
)
response = api.LocalLB.Pool.get_list
```

See specs subdir for more examples, especially as it pertains to passing parameters.

## Logging

This gem uses the [`Savon`](http://savonrb.com/) client to wrap the SOAP endpoints,
and it is sometimes useful to be able to see the SOAP request and response XML.

You can pass in a few options during configuration of the api client
which are forwarded to the internal `Savon` client:

```Ruby
api = F5::Icontrol::API.new(
    host: "hostname.of.bigip",
    username: "username",
    password: "password",

    # Savon logging options
    enable_logging: true,   # defaults to: false
    log_level: :debug,      # defaults to: debug
    pretty_print_xml: true, # defaults to: true
)

```

## CLI

There's a command line version that's still being roughed out. You'll need a `~/.f5.yml` file containing your login information:

```
default:
  host: foo.bar.com
  username: admin
  password: abc123
lb2:
  host: 1.2.3.4
  username: admin
  password: abc123
```

Then run `f5` and it'll provide help


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
