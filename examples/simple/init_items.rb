#!/usr/bin/env ruby
# coding: utf-8
require 'itemengine/sdk/request/init'

security_packet = {
    # XXX: This is a Itemengine Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => 'yis0TYCu7U9V4o7M',
	'domain'         => 'localhost'
}
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control.
# Set values in application.rb.
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'

items_request = { 'limit' => 50 }

init = Itemengine::Sdk::Request::Init.new(
	'items',
	security_packet,
	consumer_secret,
	items_request
)

puts init.generate