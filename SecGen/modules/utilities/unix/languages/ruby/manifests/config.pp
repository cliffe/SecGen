# Tunes the Ruby configuration
# Ruby's garbage colleciton is notoriously inefficient and leads to
# overallocation of memory to any long-running process that uses Ruby
# e.g. puppet daemons
# This class allows tuning of the Ruby environment variables
class ruby::config (
  $gc_malloc_limit          = undef,
  $heap_free_min            = undef,
  $heap_slots_growth_factor = undef,
  $heap_min_slots           = undef,
  $heap_slots_increment     = undef
) inherits ruby::params {

  if  $gc_malloc_limit or
      $heap_free_min or
      $heap_slots_growth_factor or
      $heap_min_slots or
      $heap_slots_increment
  {
    $ensure = 'file'
  } else{
    $ensure = 'absent'
  }

  file{'ruby_environment':
    ensure  => $ensure,
    path    => $ruby::params::ruby_environment_file,
    content => template('ruby/ruby.sh.erb'),
  }

}