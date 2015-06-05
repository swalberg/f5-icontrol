# F5::Icontrol

[![Build Status](https://travis-ci.org/swalberg/f5-icontrol.svg?branch=master)](https://travis-ci.org/swalberg/f5-icontrol)

This is the F5-control gem. If you have an F5, it can use the iControl SOAP interface to automate things

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

## Usage

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

See specs subdir for more examples, especially as it pertains to passing parameters.

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
