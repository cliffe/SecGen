# Emulate the is_absolute_path and validate_absolute_path functions
#
# The first pattern is originally from is_absolute_path, which had it from 2.7.x's lib/puppet/util.rb Puppet::Util.absolute_path?
# slash = '[\\\\/]'
# name = '[^\\\\/]+'
# %r!^(([A-Z]:#{slash})|(#{slash}#{slash}#{name}#{slash}#{name})|(#{slash}#{slash}\?#{slash}#{name}))!i,
type Stdlib::Compat::Absolute_path = Variant[Pattern[/^(([a-zA-Z]:[\\\/])|([\\\/][\\\/][^\\\/]+[\\\/][^\\\/]+)|([\\\/][\\\/]\?[\\\/][^\\\/]+))/], Pattern[/^\//]] # lint:ignore:140chars
