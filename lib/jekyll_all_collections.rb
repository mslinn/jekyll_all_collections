require 'colorator'
require_relative 'jekyll_all_collections/version'

msg = <<~END_MSG

  The jekyll_all_collections gem has been incorporated into jekyll_plugin_support, v3.
  Remove the reference to jekyll_all_collections from Gemfile.
  Halting Jekyll.

END_MSG
puts msg.yellow
exit! 2
