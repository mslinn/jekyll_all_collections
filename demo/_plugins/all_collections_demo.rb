require 'cgi'

# @author Copyright 2020 Michael Slinn
# @license SPDX-License-Identifier: Apache-2.0
module AllCollectionsDemoModule
  # This tag is just used for 2020-10-03-i-prefer-to-write-jekyll-plugins-instead-of-includes.html
  class AllCollectionsDemo < Liquid::Tag
    # Constructor.
    # @param tag_name [String] is the name of the tag, which we already know.
    # @param command_line [Hash, String, Liquid::Tag::Parser] the arguments from the web page.
    # @param tokens [Liquid::ParseContext] tokenized command line
    # @return [void]
    def initialize(tag_name, command_line, tokens)
      super(tag_name, command_line, tokens)
      @command_line = command_line.strip
    end

    # Method prescribed by the Jekyll plugin lifecycle.
    # @return [String]
    def render(liquid_context)
      site = liquid_context.registers[:site]
      JekyllAllCollections.maybe_compute_all_collections(site)
      result = site.all_collections.map do |entry|
        line = entry.map { |k, v| "<b>#{k}</b>=#{CGI.escapeHTML(v.to_s.strip)}\n" }
        "<pre>#{line.join}</pre>"
      end
      result.join("<br>\n")
    end
  end
end

Liquid::Template.register_tag('all_collections_demo', AllCollectionsDemoModule::AllCollectionsDemo)
