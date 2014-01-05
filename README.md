Travis CI testing for DokuWiki plugins
======================================

This repository contains a script that can be used in
[Travis CI](https://travis-ci.org) to setup the DokuWiki environment to test a
single plugin.

Setup
-----

Use it like this in ``.travis.yml``:

```
language: php
php:
  - "5.5"
  - "5.4"
  - "5.3"
env:
  - DOKUWIKI=master
  - DOKUWIKI=stable
  - DOKUWIKI=old-stable
before_install: wget https://raw.github.com/splitbrain/dokuwiki-travis/master/travis.sh
install: sh travis.sh
script: cd _test && phpunit --stderr --group plugin_something
```

As you can see, you can specify the PHP versions and DokuWiki releases your plugin
should be tested against.

Plugins with dependencies
-------------------------

If your tests require additional plugins to be installed, provide a ``requirements.txt``
file in your plugin's root directory. It should contain arguments to the git clone command,
eg. the source repository and the target directory. The latter needs to be a full path
in the DokuWiki hierarchy.

Here's an example ``requirements.txt`` file:

```
# additional requirements for this plugin:
https://github.com/cosmocode/sqlite.git                         lib/plugins/sqlite
https://github.com/splitbrain/dokuwiki-plugin-translation.git   lib/plugins/translation
```

If your plugin needs any additional setup before testing you need to provide your own
script to be run in the ``before_script`` step of ``.travis.yml``. Refer to the travis
docs on how to do that.

More info
---------

More info on Unit Testing in DokuWiki is available at https://www.dokuwiki.org/devel:unittesting
