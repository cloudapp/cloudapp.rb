require 'support/stub_class_or_module'
require 'English'

root = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift(File.expand_path('app/models', root))
$LOAD_PATH.unshift(File.expand_path('app/controllers', root))
$LOAD_PATH.unshift(File.expand_path('app/helpers', root))
$LOAD_PATH.unshift(File.expand_path('lib', root))
