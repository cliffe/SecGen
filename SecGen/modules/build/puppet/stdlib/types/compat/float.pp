# Emulate the is_float function
# The regex is what's currently used in is_float
# To keep your development moving forward, you can also add a deprecation warning using the Integer type:
#
# ```class example($value) { validate_float($value,) }```
#
# would turn into
#
# ```
# class example(Stdlib::Compat::Float $value) {
#   validate_float($value, 10, 0)
#   assert_type(Integer[0, 10], $value) |$expected, $actual| {
#     warning("The 'value' parameter for the 'ntp' class has type ${actual}, but should be ${expected}.")
#   }
# }
# ```
#
# This allows you to find all places where a consumers of your code call it with unexpected values.
type Stdlib::Compat::Float = Variant[Float, Pattern[/^-?(?:(?:[1-9]\d*)|0)(?:\.\d+)(?:[eE]-?\d+)?$/]]
