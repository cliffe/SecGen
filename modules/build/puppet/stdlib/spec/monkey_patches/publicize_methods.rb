#! /usr/bin/env ruby -S rspec
# Some monkey-patching to allow us to test private methods.
class Class
  def publicize_methods(*methods)
    saved_private_instance_methods = methods.empty? ? private_instance_methods : methods

    class_eval { public(*saved_private_instance_methods) }
    yield
    class_eval { private(*saved_private_instance_methods) }
  end
end
