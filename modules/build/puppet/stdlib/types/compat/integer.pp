# Emulate the is_integer and validate_integer functions
# The regex is what's currently used in is_integer
# validate_numeric also allows range checking, which cannot be mapped to the string parsing inside the function.
# For full backwards compatibility, you will need to keep the validate_numeric call around to catch everything.
# To keep your development moving forward, you can also add a deprecation warning using the Integer type:
#
# ```class example($value) { validate_integer($value, 10, 0) }```
#
# would turn into
#
# ```
# class example(Stdlib::Compat::Integer $value) {
#   validate_numeric($value, 10, 0)
#   assert_type(Integer[0, 10], $value) |$expected, $actual| {
#     warning("The 'value' parameter for the 'ntp' class has type ${actual}, but should be ${expected}.")
#   }
# }
# ```
#
# > Note that you need to use Variant[Integer[0, 10], Float[0, 10]] if you want to match both integers and floating point numbers.
#
# This allows you to find all places where a consumers of your code call it with unexpected values.
type Stdlib::Compat::Integer = Variant[Integer, Pattern[/^-?(?:(?:[1-9]\d*)|0)$/], Array[Variant[Integer, Pattern[/^-?(?:(?:[1-9]\d*)|0)$/]]]] # lint:ignore:140chars
