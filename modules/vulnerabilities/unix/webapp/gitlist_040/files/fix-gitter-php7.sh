#!/bin/bash
# Fix PHP 7.2+ incompatibility in GitList 0.4.0's bundled Gitter library.
# PHP 7.2+ reserved 'Object' as a class name; Gitter uses it in its model
# classes. This script renames it to GitObject throughout the vendor tree
# and updates the Composer autoloader classmap.
set -e

GITTER=/var/www/gitlist/vendor/klaussilveira/gitter
COMPOSER=/var/www/gitlist/vendor/composer
VENDOR=/var/www/gitlist/vendor

# 1. Rename the class definition in Object.php
sed -i 's/^class Object /class GitObject /' "$GITTER/lib/Gitter/Model/Object.php"

# 2. Update 'extends Object' in Gitter model files (Blob, Tree, Commit, Tag, etc.)
find "$GITTER" -name '*.php' | xargs -r sed -i \
  's/extends Object {/extends GitObject {/g;
   s/extends Object$/extends GitObject/g'

# 3. Update 'use Gitter\Model\Object;' references (PHP namespace, single backslashes)
find "$VENDOR" -name '*.php' | xargs -r sed -i \
  's/use Gitter\\Model\\Object;/use Gitter\\Model\\GitObject;/g'

# 4. Update Composer autoloader classmaps (PHP strings use double-backslash for namespaces)
find "$COMPOSER" -name '*.php' | xargs -r sed -i \
  's/Gitter\\\\Model\\\\Object/Gitter\\\\Model\\\\GitObject/g'
