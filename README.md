[![Gem Version](https://badge.fury.io/rb/esxi@2x.png)](http://badge.fury.io/rb/esxi)

# Esxi

A simple gem written to solve only once purpose - Interact with ESXI

## Installation

Add this line to your application's Gemfile:

    gem 'esxi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install esxi

## Usage

    `require 'esxi'`
    `esxi = VM.new({"host"=>"#{IP}", "user"=>"#{USER}", "password"=>"#{PASSWORD}", "port"=>"22"})`
    `esxi.get_snapshots 1`
    `esxi.create 1 name description`

Not tested extensively yet. 

## TODO

Write test Cases.

## Contributing

1. Fork it ( https://github.com/prashanthrajagopal/esxi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
