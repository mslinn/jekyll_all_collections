# `jekyll_all_collections` [![Gem Version](https://badge.fury.io/rb/jekyll_all_collections.svg)](https://badge.fury.io/rb/jekyll_all_collections)


`Jekyll_all_collections` is a Jekyll plugin that includes a generator,
triggered by a high-priority hook, and a block tag called `all_collections`.


## Generator

The generator adds four new attributes to
[`site`](https://jekyllrb.com/docs/variables/#site-variables):
`all_collections`, `all_documents`, `everything`, and `sorted_lru_files`.

These three attributes can be referenced as `site.everything`, `site.all_collections`
and `site.all_documents`.

* `all_collections` includes all documents in all collections.

* `all_documents` includes `all_collections` plus all standalone pages.

* `everything` includes `all_documents` plus all static files.

* `sorted_lru_files` is used by a new binary search lookup for matching page suffixes.
  Currently only `jekyll_href` and `jekyll_draft` use this feature.


### Collection Management

Jekyll provides inconsistent attributes for
[`site.pages`](https://jekyllrb.com/docs/pages/),
[`site.posts`](https://jekyllrb.com/docs/posts/) and
[`site.static_files`](https://jekyllrb.com/docs/static-files/).


* While the `url` attributes of items in `site.posts` and `site.pages` start with a slash (/),
  `site.static_files` items do not have a `url` attribute.
* Static files have a `relative_path` attribute, which starts with a slash (/),
  but although that attribute is also provided in `site.posts` and `site.pages`,
  those values do not start with a slash.
* Paths ending with a slash (`/`) imply that a file called `index.html` should be fetched.
* HTML redirect files created by the
  [`jekyll-redirect-from`](https://github.com/jekyll/jekyll-redirect-from) Jekyll plugin,
  which are included in `site.static_files`, should be ignored.

These inconsistencies mean that combining the standard three collections of files
provided as `site` attributes will create a new collection that is difficult
to process consistently:

```ruby
# This pseudocode creates `oops`, which is problematic to process consistently
oops = site.all_collections + site.pages + site.static_files
```

`oops`, above, is difficult to process because of inconsistencies in the provided attributes
and how the attributes are constructed.


### Solving The Problem

The generator normalizes these inconsistencies by utilizing the `APage` class
and filtering out HTML redirect files.

The `all_collections` collection contains `APage` representations of `site.collections`.

The `all_documents` collection contains `APage` representations of `site.pages`.

The `everything` collection contains `APage` representations of:

```text
# Pseudocode
site.collections + site.pages + site.static_files - HTML_redirect_files
```


## The APage Class

The `site.all_collections`, `site.all_documents` and `site.everything` attributes
consist of arrays of [`APage`](lib/hooks/a_page.rb) instances.

The `APage` class has the following attributes:
`content` (HTML or Markdown), `data` (array), `date` (Ruby Date), `description`, `destination`,
`draft` (Boolean), `ext`, `href`, `label`, `last_modified` or `last_modified_at` (Ruby Date),
`layout`, `origin`, `path`, `relative_path`, `tags`, `title`, `type`, and `url`.

* `href` always starts with a slash.
  This value is consistent with `a href` values in website HTML.
  Paths ending with a slash (`/`) have `index.html` appended so the path specifies an actual file.

* `origin` indicates the original source of the item.
  Possible values are `collection`, `individual_page` and `static_file`.
  Knowing the origin of each item allows code to process each type of item appropriately.


## Block Tag

The `all_collections` block tag creates a formatted listing of Jekyll files.
The ordering is configurable; by default, the listing is sorted by `date`, newest to oldest.
The `all_collections` tag has a `data_source` parameter that specifies which new property to report on
(`all_collections`, `all_documents`, or `everything`).


## Installation

### Installing In A Jekyll Website

1. Add the CSS found in
   [`demo/assets/css/jekyll_all_collections.css`](demo/assets/css/jekyll_all_collections.css)
   to your Jekyll layout(s).

2. Add the following to your Jekyll website's `Gemfile`, within the `jekyll_plugins` group:

   ```ruby
   group :jekyll_plugins do
     gem 'jekyll_all_collections', '>= 0.3.8'
     gem 'jekyll_draft', '>=2.1.0'
   end
   ```

3. Type:

   ```shell
   $ bundle
   ```


### Installing As a Gem Dependency

1. Add the following to your gem&rsquo;s `.gemspec`:

   ```ruby
   spec.add_dependency 'jekyll_all_collections', '>= 0.3.8'
   spec.add_dependency 'jekyll_draft', '>=2.1.0'
   ```

2. Type:

   ```shell
   $ bundle
   ```


## Demo

The [`demo`](./demo) directory contains a demonstration website, which uses the plugin.
To run, type:

```console
$ bin/setup
$ demo/_bin/debug -r
```

Now point your web browser to http://localhost:4444


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

### New `Site` Attributes

No explicit initialization or setup is required.
Jekyll plugins can access the value of
`site.all_collections`, `site.all_documents` and `site.everything`;
however, Liquid code in Jekyll pages and documents cannot.


### Excluding Files

There are two ways to exclude files from the new `site` attributes.

1) The [`exclude` entry in `_config.yml`](https://jekyllrb.com/docs/configuration/options#global-configuration)
   can be used as it normally would.

2) Adding the following entry to a page&rsquo;s front matter causes that page to be excluded
  from the collection created by this plugin:

   ```html
   ---
   exclude_from_all: true
   ---
   ```


### Plugin Usage

Jekyll generators and tags receive an enhanced version of the `site` Jekyll variable.


#### From a Custom Plugin

In the following example of how to use the `all_collections` plugin in a custom plugin,
the `do_something_with` function processes all `Jekyll::Page`s, `Jekyll:Document`s, and static files.

```ruby
@site.everything.each do |apage|
  do_something_with apage
end
```


#### Using the Block Tag

The general form of the Jekyll tag, including all options, is:

```html
{% all_collections
  date_column='date|last_modified'
  heading='All Posts'
  id='asdf'
  sort_by='SORT_KEYS'
%}
```


##### `date_column` Attribute

One of two date columns can be displayed in the generated HTML:
either `date` (when the article was originally written),
or `last_modified`.
The default value for the `date_column` attribute is `date`.


##### `heading` Attribute

If no `heading` attribute is specified, a heading will automatically be generated, which contains the `sort_by` values,
for example:

```html
{% all_collections id='abcdef' sort_by="last_modified" %}
```

The above generates a heading like:

```html
<h2 id="abcdef">All Posts Sorted By last_modified</h2>
```

To suppress both a `h2` heading (and the enclosed `id`) from being generated,
specify an empty string for the value of `heading`:

```html
{% all_collections heading='' %}
```


##### `id` Attribute

If your Jekyll layout employs [`jekyll-toc`](https://github.com/allejo/jekyll-toc), then `id` attributes are important.
The `jekyll-toc` include checks for `id` attributes in `h2` ... `h6` tags, and if found,
and if the attribute value is enclosed in double quotes
(`id="my_id"`, not single quotes like `id='my_id'`),
then the heading is included in the table of contents.

To suppress an `id` from being generated,
and thereby preventing the heading from appearing in the automatically generated table of contents from `jekyll-toc`,
specify an empty string for the value of `id`, like this:

```html
{% all_collections id='' %}
```


##### `SORT_KEYS` Values

`SORT_KEYS` specifies how to sort the collection.
Values can include one or more of the following attributes:
`date`, `destination`, `draft`, `label`, `last_modified`, `last_modified_at`, `path`, `relative_path`,
`title`, `type`, and `url`.
Ascending sorts are the default; however, a descending sort can be achieved by prepending `-` before an attribute.

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

Following are examples of how to specify the sort parameters.

**Explicitly express the default sort**<br>
(sort by the date originally written, newest to oldest):

```html
{% all_collections sort_by="-date" %}
```

Sort by date, from oldest to newest:

```html
{% all_collections sort_by="date" %}
```

**Sort by the date last modified, oldest to newest:**

```html
{% all_collections sort_by="last_modified" %}
```

**Sort by the date last modified, newest to oldest:**

```html
{% all_collections sort_by="-last_modified" %}
```

**Several attributes can be specified as sort criteria**<br>
by passing them as a comma-delimited string.
Included spaces are ignored:

```html
{% all_collections sort_by="-last_modified, -date" %}
{% all_collections sort_by="-last_modified, title" %}
{% all_collections sort_by="-last_modified, -date, title" %}
```

**The following two examples produce the same output:**

```html
{% all_collections sort_by="-last_modified,-date" %}
{% all_collections sort_by="-last_modified, -date" %}
```


## Debugging

You can control the verbosity of log output by adding the following to `_config.yml` in your Jekyll project:

```yaml
plugin_loggers:
  AllCollectionsTag::AllCollectionsTag: warn
```

1. First set breakpoints in the Ruby code that interests you.

2. You have several options for initiating a debug session:

   1. Use the **Debug Demo** Visual Studio Code launch configuration.

   2. Type the `demo/_bin/debug` command, without the `-r` options shown above.

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

   3. Run `bin/attach` and pass the directory name of a Jekyll website that has a suitable script called `_bin/debug`.
      The `demo` subdirectory fits this description.

      ```console
      $ bin/attach demo
      Successfully uninstalled jekyll_all_collections-0.1.2
      jekyll_all_collections 0.1.2 built to pkg/jekyll_all_collections-0.1.2.gem.
      jekyll_all_collections (0.1.2) installed.
      Fast Debugger (ruby-debug-ide 0.7.3, debase 0.2.4.1, file filtering is supported) listens on 0.0.0.0:1234
      ```


3. Attach to the debugger process if required.
  This git repo includes two [Visual Studio Code launch configurations](./.vscode/launch.json) for this purpose labeled
  **Attach rdbg** and **Attach with ruby_lsp**.

4. Point your web browser to http://localhost:4444

If a debugging session terminates abruptly and leaves ports tied up,
run the `demo/_bin/release_port` script.


## Additional Information

More information is available on Mike Slinn's website about
[Jekyll plugins](https://mslinn.com/jekyll_plugins/jekyll_all_collections.html).


## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.


### Build and Install Locally

To build and install this gem onto your local machine, run:

```shell
$ bundle exec rake install
jekyll_all_collections 0.3.8 built to pkg/jekyll_all_collections-0.3.8.gem.
jekyll_all_collections (0.3.8) installed.
```

Examine the newly built gem:

```shell
$ gem info jekyll_all_collections

*** LOCAL GEMS ***

jekyll_all_collections (0.3.8)
    Author: Mike Slinn
    Homepage:
    https://www.mslinn.com/jekyll_plugins/jekyll_all_collections.html
    License: MIT
    Installed at (0.3.8): /home/mslinn/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0

    Provides normalized collections and extra functionality for Jekyll websites.
```


### Build and Push to RubyGems

To release a new version:

1. Update the version number in `version.rb`.
2. Add an entry in `CHANGELOG.md` describing the changes since the last release.
3. Commit all changes to git; if you don't the next step might fail with a confusing error message.
4. Run the following:

    ```shell
    $ bundle exec rake release
    ```

    The above creates a git tag for the version, commits the created tag,
    and pushes the new `.gem` file to [RubyGems.org](https://rubygems.org).


## Contributing

1. Fork the project.
2. Create a descriptively named feature branch.
3. Add your feature.
4. Submit a pull request.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
