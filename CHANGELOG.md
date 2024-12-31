# Changelog

## 0.3.8 / 2024-12-30

* Added `AllCollectionsHooks.all_collections` and `AllCollectionsHooks.site` properties,
  accessible from every other module.


## 0.3.7 / 2024-12-21

* `AllCollectionsTag.class.evaluate` made compatible with Ruby 3.2.2.


## 0.3.6 / 2024-07-23

* Made compatible with module renaming in JekyllPluginSupport v1.0.0.


## 0.3.5 / 2024-03-26

* Added `APage.extname` for compatibility with Jekyll
  [`Document`](https://github.com/jekyll/jekyll/blob/master/lib/jekyll/document.rb);
  previously, the filetype of the uri was provided only as `APage.ext`.


## 0.3.4 / 2023-12-24

* Changed dependency to Jekyll >= 4.3.2.


## 0.3.3 / 2023-05-22

* Corrected key presence checks in APage.initialize
* Using `warn_short_trace` from `jekyll_plugin_support` for non-fatal errors.


## 0.3.2 / 2023-04-05

* Modified dependency `'jekyll_plugin_support', '>= 0.5.0'`.


## 0.3.1 / 2023-03-16

* Reduced the verbosity of the `@logger` message.

## 0.3.0 / 2023-02-16

* Updated dependency `'jekyll_plugin_support', '~> 0.5.0'`.

## 0.2.2 / 2023-02-12

* Updated dependency `'jekyll_plugin_support', '~> 0.4.0'`.


## 0.2.1 / 2023-02-12

* Reduced the verbosity of log output from `info` to `debug`.


## 0.2.0 / 2023-02-04

* Returns Array[APage] instead of a collection of different types of objects.
* Converted the plugin to a `:site, :post_read` hook instead of a tag,
    so explicit initialization is no longer required.


## 0.1.1 / 2022-04-27

* Changed invocation from a `:site` hook to an idempotent method invocation.


## 0.1.0 / 2022-04-26

* Initial version published.
