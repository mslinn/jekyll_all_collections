# `jekyll_all_collections` [![Gem Version](https://badge.fury.io/rb/jekyll_all_collections.svg)](https://badge.fury.io/rb/jekyll_all_collections)


`Jekyll_all_collections` is a Jekyll plugin that adds new properties called `all_collections`,
`all_documents` and `everything` to `site`.

It also provides a new Jekyll tag called `all_collections`,
which creates a formatted listing of all posts and documents from all collections,
sorted by age, newest to oldest.
The Jekyll tag can do the same for `everything`.

The `all_collections` collection consists of an array of objects with the following properties:
`content` (HTML or Markdown), `data` (array), `date` (Ruby Date), `description`, `destination`,
`draft` (Boolean), `excerpt` (HTML or Markdown), `ext`, `label`, `last_modified` or `last_modified_at` (Ruby Date),
`layout`, `path`, `relative_path`, `tags`, `title`, `type`, and `url`.

See [`site.pages`](https://jekyllrb.com/docs/pages/) and [`site.posts`](https://jekyllrb.com/docs/posts/) and [`site.static_files`](https://jekyllrb.com/docs/static-files/).

You *could* combine all three collections like this:

```ruby
site.all_collections + site.pages + site.static_files
```

HOWEVER:

* While the `url` attributes of pages and documents in a collection starts with a slash (/),
  static files do not have a `url` attribute.
* Static files have a `relative_path` attribute, which starts with a slash (/),
  but although that attribute is also provided in pages and documents in a collection, those values do not start with a slash.

SO:

The `everything` collection contains `site.all_collections + site.pages + site.static_files`,
with a few attributes added to each item:

* `href` always starts with a slash.
  This value is consistent with `a href` values in website HTML.

* `origin` indicates the original source of the item.
  Possible values are `collection`, `individual_page` and `static_file`.
  Knowing the origin of each item allows code to process each type of item appropriately.


## Installation

Add this line to your application's Gemfile:

```ruby
group :jekyll_plugins do
  gem 'jekyll_all_collections'
end
```

And then execute:

```shell
$ bundle
```


## Requirements

All the pages in the Jekyll website must have an implicit date
(for example, all posts are assigned this property by Jekyll),
or an explicit `date` set in front matter, like this:

```html
---
date: 2022-01-01
---
```

If a front matter variable called `last_modified` or `last_modified_at` exists,
its value will be converted to a Ruby `Date`:

```html
---
last_modified: 2023-01-01
---
```

Or:

```html
---
last_modified_at: 2023-01-01
---
```

Otherwise, if `last_modified` or `last_modified_at` is not present in the front matter for a page,
the `date` value will be used last modified date value.


## Usage

### `Site.all_collections`

No explicit initialization or setup is required.
Jekyll plugins can access the value of `site.all_collections`, however Liquid code in Jekyll pages and documents cannot.


### Plugin Usage

Jekyll generators and tags receive an enhanced version of the `site` Jekyll variable.
A new array of `APage` instance called `all_collections` is added, one for each Jekyll document and page.
Examine [`APage.rb`](https://github.com/mslinn/jekyll_all_collections/blob/v0.3.4/lib/all_collections_hooks.rb#L68-L102)
to see the available properties.
One particularly useful property is `url`, which is difficult to obtain from Jekyll.

All `Jekyll::Page`s and `Jekyll:Document`s can be processed with the following sample code:

```ruby
(@site.all_collections + @site.pages).each do |page_or_apage|
  do_something_with page_or_apage
end
```


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


#### Excluding Pages

Adding the following entry to a page&rsquo;s front matter causes that page to be excluded
from the collection created by this plugin:

```html
---
exclude_from_all: true
---
```


#### General Form

The general form of the Jekyll tag is:

```html
{% all_collections
  date_column='date|last_modified'
  heading='All Posts'
  id='asdf'
  sort_by='SORT_KEYS'
%}
```


#### `date_column` Attribute

One of two date columns can be displayed in the generated HTML:
either `date` (when the article was originally written),
or `last_modified`.
The default value for the `date_column` attribute is `date`.


#### `heading` Attribute

If no `heading` attribute is specified, a heading will automatically be generated, which contains the `sort_by` values,
for example:

```html
{% all_collections id='abcdef' sort_by="last_modified" %}
```

Generates a heading like:

```html
<h2 id="abcdef">All Posts Sorted By last_modified</h2>
```

To suppress both a `h2` heading (and the enclosed `id`) from being generated,
specify an empty string for the value of `heading`:

```html
{% all_collections heading='' %}
```


#### `id` Attribute

If your Jekyll layout employs [`jekyll-toc`](https://github.com/allejo/jekyll-toc), then `id` attributes are important.
The `jekyll-toc` include checks for `id` attributes in `h2` ... `h6` tags, and if found,
and if the attribute value is enclosed in double quotes (`id="my_id"`, not `id='my_id'`),
then the heading is included in the table of contents.

To suppress an `id` from being generated,
and thereby preventing the heading from appearing in the automatically generated table of contents from `jekyll-toc`,
specify an empty string for the value of `id`, like this:

```html
{% all_collections id='' %}
```


#### `SORT_KEYS` Values

`SORT_KEYS` specifies how to sort the collection.
Values can include one or more of the following attributes:
`date`, `destination`, `draft`, `label`, `last_modified`, `last_modified_at`, `path`, `relative_path`,
`title`, `type`, and `url`.
Ascending sorts are the default, however a descending sort can be achieved by prepending `-` before an attribute.

To specify more than one sort key, provide a comma-delimited string of values.
Included spaces are ignored.
For example, specify the primary sort key as `draft`,
the secondary sort key as `last_modified`,
and the tertiary key as `label`:

```html
{% all_collections
  date_column='last_modified'
  heading='All Posts'
  id='asdf'
  sort_by='draft, last_modified, label'
%}
```


#### Liquid Usage Examples

Here is a short Jekyll page, including front matter,
demonstrating this plugin being invoked with all default attribute values:

```html
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

```html
{% all_collections sort_by="-date" %}
```

Sort by date, from oldest to newest:

```html
{% all_collections sort_by="date" %}
```

Sort by the date last modified, oldest to newest:

```html
{% all_collections sort_by="last_modified" %}
```

Sort by the date last modified, newest to oldest:

```html
{% all_collections sort_by="-last_modified" %}
```

Several attributes can be specified as sort criteria by passing them as a comma-delimited string.
Included spaces are ignored:

```html
{% all_collections sort_by="-last_modified, -date" %}
{% all_collections sort_by="-last_modified, title" %}
{% all_collections sort_by="-last_modified, -date, title" %}
```

The following two examples produce the same output:

```html
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

You can control the verbosity of log output by adding the following to `_config.yml` in your Jekyll project:

```yaml
plugin_loggers:
  AllCollectionsTag::AllCollectionsTag: warn
```


1. You have two options for initiating a debug session:

   1. Run `demo/_bin/debug`, without the `-r` options shown above.

      ```console
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


## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.


### Build and Install Locally

To build and install this gem onto your local machine, run:

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
