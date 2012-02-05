def stub_module(full_name, &block)
  stub_class_or_module full_name, Module, &block
end

def stub_class(full_name, &block)
  stub_class_or_module full_name, Class, &block
end

def stub_class_or_module(full_name, kind, &block)
  full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      context.const_get(name)
    rescue NameError
      context.const_set(name, kind.new)
    end
  end

  Object.const_get(full_name).class_eval &block if block
end
