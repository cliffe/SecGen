# Boolean check to determine whether a variable is of a given data type. This is equivalent to the `=~` type checks.
#
# @example how to check a data type
#   # check a data type
#       foo = 3
#       $bar = [1,2,3]
#       $baz = 'A string!'
#
#       if $foo.is_a(Integer) {
#         notify  { 'foo!': }
#       }
#       if $bar.is_a(Array) {
#         notify { 'bar!': }
#       }
#       if $baz.is_a(String) {
#         notify { 'baz!': }
#       }
#
# See the documentation for "The Puppet Type System" for more information about types.
# See the `assert_type()` function for flexible ways to assert the type of a value.
#
Puppet::Functions.create_function(:is_a) do
  dispatch :is_a do
    param 'Any', :value
    param 'Type', :type
  end

  def is_a(value, type)
    # See puppet's lib/puppet/pops/evaluator/evaluator_impl.rb eval_MatchExpression
    Puppet::Pops::Types::TypeCalculator.instance?(type, value)
  end
end
