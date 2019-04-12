# Emulate the is_numeric and validate_numeric functions
# The regex is what's currently used in is_numeric
# validate_numeric also allows range checking, which cannot be mapped to the string parsing inside the function.
# For full backwards compatibility, you will need to keep the validate_numeric call around to catch everything.
# To keep your development moving forward, you can also add a deprecation warning using the Integer type:
#
# ```class example($value) { validate_numeric($value, 10, 0) }```
#
# would turn into
#
# ```
# class example(Stdlib::Compat::Numeric $value) {
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
type Stdlib::Compat::Numeric = Variant[Numeric, Pattern[/^-?(?:(?:[1-9]\d*)|0)(?:\.\d+)?(?:[eE]-?\d+)?$/], Array[Variant[Numeric, Pattern[/^-?(?:(?:[1-9]\d*)|0)(?:\.\d+)?(?:[eE]-?\d+)?$/]]]]
