#!/bin/sh
#
# This script sets up a DokuWiki environment to run the plugin's tests on
# travis-ci.org or gitlab-ci.
# The plugin itself will be moved to its correct location within the DokiWiki
# hierarchy.
#
# @author Andreas Gohr <andi@splitbrain.org>

# make sure this runs on travis only
if [ -z "$TRAVIS" ] && [ -z "$CI_SERVER" ]  ; then
    echo 'This script is only intended to run on travis-ci.org or gitlab-ci build servers'
    exit 1
fi

# check we're in the right working directory and have tests
if [ ! -d '_test' ]; then
    echo 'No _test directory found, script was probably called from the wrong working directory'
    exit 1
fi

# check if template or plugin
if [ -e 'plugin.info.txt' ]; then
    type='plugin'
    dir='plugins'
elif [ -e 'template.info.txt' ]; then
    type='template'
    dir='tpl'
else
    echo 'No plugin.info.txt or template.info.txt found!'
    exit 1
fi

# find out where this plugin belongs to
BASE=$(awk '/^base/{print $2}' ${type}.info.txt)
if [ -z "$BASE" ]; then
    echo "This plugins misses a base entry in ${type}.info.txt"
    exit 1
fi

# move everything to the correct location
echo ">MOVING TO: lib/$dir/$BASE"
mkdir -p "lib/$dir/$BASE"
mv ./* "lib/$dir/$BASE/" 2>/dev/null
mv .[a-zA-Z0-9_-]* "lib/${dir}/$BASE/"

# checkout DokuWiki into current directory (no clone because dir isn't empty)
# the branch is specified in the $DOKUWIKI environment variable
echo ">CLONING DOKUWIKI: $DOKUWIKI"
git init
git pull https://github.com/splitbrain/dokuwiki.git "$DOKUWIKI"

# install additional requirements
REQUIRE="lib/${dir}/$BASE/requirements.txt"
if [ -f "$REQUIRE" ]; then
    grep -v '^#' "$REQUIRE" | \
    while read -r LINE
    do
        if [ -n "$LINE" ]; then
            echo ">REQUIREMENT: $LINE"
            git clone $LINE
        fi
    done
fi

# figure out the currently tested PHP version
PHPV=$(php -v | grep -Po '(?<=PHP )([0-9].[0-9])')
echo "> RUNNING PHP $PHPV"

# download the proper phpunit
if [ "$PHPV" = "5.6" ]; then
    PHPUNIT='phpunit-5.phar'
elif [ "$PHPV" = "7.0" ]; then
    PHPUNIT='phpunit-6.phar'
elif [ "$PHPV" = "7.4" ]; then
    PHPUNIT='phpunit-8.phar'
else
    PHPUNIT='phpunit-7.phar'
fi
wget "https://phar.phpunit.de/$PHPUNIT" -O _test/phpunit.phar || exit 1
chmod 755 _test/phpunit.phar
echo ">DOWNLOADED $PHPUNIT"

# we now have a full dokuwiki environment with our plugin installed
# travis can take over
exit 0
