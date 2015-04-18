#!/usr/bin/env ruby

$: << Dir.getwd
require 'lib/josh'

puts "Loading Josh Bot"
Josh::Bot.new.boot!
