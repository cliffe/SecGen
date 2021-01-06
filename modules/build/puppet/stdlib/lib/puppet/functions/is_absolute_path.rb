Puppet::Functions.create_function(:is_absolute_path) do
  dispatch :deprecation_gen do
    param 'Any', :scope
    repeated_param 'Any', :args
  end
  # Workaround PUP-4438 (fixed: https://github.com/puppetlabs/puppet/commit/e01c4dc924cd963ff6630008a5200fc6a2023b08#diff
  #   -c937cc584953271bb3d3b3c2cb141790R221) to support puppet < 4.1.0 and puppet < 3.8.1.
  def call(scope, *args)
    manipulated_args = [scope] + args
    self.class.dispatcher.dispatch(self, scope, manipulated_args)
  end

  def deprecation_gen(scope, *args)
    call_function('deprecation', 'is_absolute_path', 'This method is deprecated, please use match expressions with Stdlib::Compat::Absolute_Path instead. They are described at https://docs.puppet.com/puppet/latest/reference/lang_data_type.html#match-expressions.')
    scope.send('function_is_absolute_path', args)
  end
end
