#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/compote'
require_relative '../lib/compote/cli'

Compote.with_gracious_interrupt do
  Compote::Cli.commands.run! ARGV.shift, ARGV
end
