module Stubbed end

def stub_module(full_name, &block)
  stub_class_or_module full_name, Module, &block
end

def stub_class(full_name, &block)
  stub_class_or_module full_name, Class, &block
end

def stub_class_or_module(full_name, kind, &block)
  stub = full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      context.const_get(name)
    rescue NameError
      stubbed = kind.new do include(Stubbed) end
      context.const_set(name, stubbed)
    end
  end

  stub.class_eval &block if block
end
