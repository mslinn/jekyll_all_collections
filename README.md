`jekyll_all_collections`
[![Gem Version](https://badge.fury.io/rb/jekyll_all_collections.svg)](https://badge.fury.io/rb/jekyll_all_collections)
===========

<style type="text/css">
  ol    { list-style-type: decimal;}
  ol ol {list-style-type: lower-alpha;}
</style>

`Jekyll_all_collections` is a Jekyll plugin that adds a new property called `all_collections` to `site`.
It also provides a new Jekyll tag called `all_collections`, which creates a formatted listing of all posts and documents from all collections, sorted by age.

The collection consists of an array of objects with the following properties:
`content` (HTML or Markdown), `data` (array), `date` (Ruby Date), `description`, `destination`,
`draft` (Boolean), `excerpt` (HTML or Markdown), `ext`, `label`, `last_modified` (Ruby Date),
`layout`, `path`, `relative_path`, `tags`, `title`, `type`, and `url`.


## Usage

### `Site.all_collections`
No explicit initialization or setup is required.
Jekyll plugins can access the value of `site.all_collections`, however Liquid code in Jekyll pages and documents cannot.


### `All_collections` Tag
Add the following CSS to your stylesheet:
```css
.posts {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  line-height: 170%;
}

.posts > *:nth-child(odd) {
  width: 120px;
  font-family: Monaco,"Bitstream Vera Sans Mono", "Lucida Console", Terminal, monospace;
  font-stretch: semi-condensed;
  font-size: 10pt;
}

.posts > *:nth-child(even) {
  width: calc(100% - 120px);
}
```

#### General Form
The general form of the Jekyll tag is:
```
{% all_collections id='asdf' heading='All Posts' sort_by='SORT_KEYS' %}
```

#### `id` Attribute
If your Jekyll layout employs [`jekyll-toc`](https://github.com/allejo/jekyll-toc), then `id` attributes are important.
The `jekyll-toc` include checks for `id` attributes in `h2` ... `h6` tags, and if found, and if the attribute value is enclosed in double quotes (`id="my_id"`, not `id='my_id'`),
then the heading is included in the table of contents.

To suppress an `id` from being generated,
and thereby preventing the heading from appearing in the automatically generated table of contents from `jekyll-toc`,
specify an empty string for the value of `id`, like this:
```
{% all_collections id='' %}
```

#### `heading` Attribute
If no `heading` attribute is specified, a heading will automatically be generated, which contains the `sort_by` values, for example:
```
{% all_collections id='abcdef' sort_by="last_modified" %}
```
Generates a heading like:
```
<h2 id="abcdef">All Posts Sorted By -last_modified</h2>
```

To suppress both a `h2` heading (and the enclosed `id`) from being generated,
specify an empty string for the value of `heading`:
```
{% all_collections heading='' %}
```

#### `SORT_KEYS` Values
`SORT_KEYS` specifies how to sort the collection.
Values can include one or more of the following attributes:
`date`, `destination`, `draft`, `label`, `last_modified`, `path`, `relative_path`, `title`, `type`, and `url`.
Ascending sorts are the default, however a descending sort can be achieved by prepending `-` before an attribute.

To specify more than one sort key, provide an array of values.

#### Usage Examples
Here is a short Jekyll page, including front matter,
demonstrating this plugin being invoked with all default attribute values:
```
---
description: "
  Dump of all collections, sorted by date originally written, newest to oldest.
  The heading text will be <code>All Posts Sorted By -date</code>
"
layout: default
title: Testing, 1, 2, 3
---
{% all_collections %}
```

Explicitly express the default sort
(sort by the date originally written, newest to oldest):
```
{% all_collections sort_by="-date" %}
```

Sort by date, from oldest to newest:
```
{% all_collections sort_by="date" %}
```

Sort by the date last modified, oldest to newest:
```
{% all_collections sort_by="last_modified" %}
```

Sort by the date last modified, newest to oldest:
```
{% all_collections sort_by="-last_modified" %}
```

Several attributes can be specified as sort criteria by passing them as a comma-delimited string.
Included spaces are ignored:
```
{% all_collections sort_by="-last_modified, -date" %}
{% all_collections sort_by="-last_modified, title" %}
{% all_collections sort_by="-last_modified, -date, title" %}
```

The following two examples produce the same output:
```
{% all_collections sort_by="-last_modified,-date" %}
{% all_collections sort_by="-last_modified, -date" %}
```


## Demo
The [`demo`](./demo) directory contains a demonstration website, which uses the plugin.
To run, type:
```console
$ demo/_bin/debug -r
```
Now point your web browser to http://localhost:4444


## Debugging
1. You have two options for initiating a debug session:

   1. Run `demo/_bin/debug`, without the `-r` options shown above.
      ```
      ... lots of output as bundle update runs...
      Bundle updated!

      INFO PluginMetaLogger: Loaded AllCollectionsHooks v0.2.0 :site, :pre_render, :normal hook plugin.
      INFO PluginMetaLogger: Loaded DraftFilter plugin.
      INFO PluginMetaLogger: Loaded all_collections v0.2.0 tag plugin.
      Configuration file: /mnt/_/work/jekyll/my_plugins/jekyll_all_collections/demo/_config.yml
                Cleaner: Removing /mnt/_/work/jekyll/my_plugins/jekyll_all_collections/demo/_site...
                Cleaner: Removing /mnt/_/work/jekyll/my_plugins/jekyll_all_collections/demo/.jekyll-metadata...
                Cleaner: Removing /mnt/_/work/jekyll/my_plugins/jekyll_all_collections/demo/.jekyll-cache...
                Cleaner: Nothing to do for .sass-cache.
      Fast Debugger (ruby-debug-ide 0.7.3, debase 0.2.5.beta2, file filtering is supported) listens on 0.0.0.0:1234
      ```

   2. Run `bin/attach` and pass the directory name of a Jekyll website that has a suitable script called `_bin/debug`.
      The `demo` subdirectory fits this description.
      ```console
      $ bin/attach demo
      Successfully uninstalled jekyll_all_collections-0.1.2
      jekyll_all_collections 0.1.2 built to pkg/jekyll_all_collections-0.1.2.gem.
      jekyll_all_collections (0.1.2) installed.
      Fast Debugger (ruby-debug-ide 0.7.3, debase 0.2.4.1, file filtering is supported) listens on 0.0.0.0:1234
      ```

2. Set breakpoints in Ruby code.

3. Attach to the debugger process.
  This git repo includes a [Visual Studio Code launcher](./.vscode/launch.json) for this purpose labeled `Listen for rdebug-ide`.

4. Point your web browser to http://localhost:4444


## Additional Information
More information is available on Mike Slinn's website about
[Jekyll plugins](https://www.mslinn.com/blog/index.html#Jekyll).


## Installation
This has already been done for the demo;
these instructions are for incorporating the plugin(s) into other Jekyll websites.
Add this line to your application's Gemfile:

```ruby
group :jekyll_plugins do
  gem 'jekyll_all_collections'
end
```

And then execute:

    $ bundle install


## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.


### Build and Install Locally
To build and install this gem onto your local machine, run:
```shell
$ rake install
```

The following also does the same thing:
```shell
$ bundle exec rake install
jekyll_all_collections 0.1.0 built to pkg/jekyll_all_collections-0.1.0.gem.
jekyll_all_collections (0.1.0) installed.
```

Examine the newly built gem:
```shell
$ gem info jekyll_all_collections

*** LOCAL GEMS ***

jekyll_all_collections (0.1.0)
    Author: Mike Slinn
    Homepage: https://www.mslinn.com/blog/2020/12/30/jekyll-plugin-template-collection.html
    License: MIT
    Installed at: /home/mslinn/.rbenv/versions/3.1.0/lib/ruby/gems/3.1.0

    Provides a collection of all collections in site.all_collections.
```


### Build and Push to RubyGems
To release a new version,
  1. Update the version number in `version.rb`.
  2. Commit all changes to git; if you don't the next step might fail with an unexplainable error message.
  3. Run the following:
     ```shell
     $ bundle exec rake release
     ```
     The above creates a git tag for the version, commits the created tag,
     and pushes the new `.gem` file to [RubyGems.org](https://rubygems.org).


## Contributing

1. Fork the project
2. Create a descriptively named feature branch
3. Add your feature
4. Submit a pull request


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
