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

# 2. Update 'extends Object' in Gitter model files (Blob, Tree, Commit, Tag, etc.).
#    Match 'extends Object' at a trailing word boundary so it also catches a
#    class that puts an interface after the parent (Tree is
#    'class Tree extends Object implements \RecursiveIterator'), not only the
#    'extends Object {' and end-of-line forms. Missing Tree left its parent
#    class undefined, so GitList's /tree/ endpoint raised a fatal and listed no
#    files, which broke the repository file browser (and the file discovery that
#    exploit/multi/http/gitlist_arg_injection relies on).
find "$GITTER" -name '*.php' | xargs -r sed -i \
  's/extends Object\b/extends GitObject/g'

# 3. Update 'use Gitter\Model\Object;' references (PHP namespace, single backslashes)
find "$VENDOR" -name '*.php' | xargs -r sed -i \
  's/use Gitter\\Model\\Object;/use Gitter\\Model\\GitObject;/g'

# 4. Update Composer autoloader classmaps (PHP strings use double-backslash for namespaces)
find "$COMPOSER" -name '*.php' | xargs -r sed -i \
  's/Gitter\\\\Model\\\\Object/Gitter\\\\Model\\\\GitObject/g'
