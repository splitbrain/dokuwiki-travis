Travis CI testing for DokuWiki plugins
======================================

This repository contains a script that can be used in
[Travis CI](https://travis-ci.org) to setup the DokuWiki environment to test a
single plugin.

Use it like this in ``.travis.yml``:

```
language: php
php:
  - "5.5"
  - "5.4"
  - "5.3"
before_install: wget https://raw.github.com/splitbrain/dokuwiki-travis/master/travis.sh
install: sh travis.sh
script: cd _test && phpunit --stderr --group plugin_something
```

If your tests require additional plugins to be installed, provide a script
to download them in ``before_script``.

More info on Unit Testing in DokuWiki is available at https://www.dokuwiki.org/devel:unittesting
