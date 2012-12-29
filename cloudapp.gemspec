## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'cloudapp'
  s.version           = '2.0.0.beta.9'
  s.date              = '2012-12-28'
  s.rubyforge_project = 'cloudapp'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "CloudApp CLI"
  s.description = "Experience all the pleasures of sharing with CloudApp now in your terminal."

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Larry Marburger"]
  s.email    = 'larry@marburger.cc'
  s.homepage = 'https://github.com/cloudapp/cloudapp'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## If your gem includes any executables, list them here.
  s.executables = ["cloudapp"]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md MIT-LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency 'clipboard',  '~> 1.0.1'
  s.add_dependency 'leadlight',  '~> 0.1.0'
  s.add_dependency 'mime-types', '~> 1.19'
  s.add_dependency 'netrc',      '~> 0.7.7'
  s.add_dependency 'typhoeus',   '~> 0.3.3'

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency 'rake'
  s.add_development_dependency 'ronn'
  s.add_development_dependency 'rspec'

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    Gemfile.lock
    MIT-LICENSE
    README.md
    Rakefile
    bin/cloudapp
    cloudapp.gemspec
    lib/cloudapp.rb
    lib/cloudapp/authorized.rb
    lib/cloudapp/cli/prompt.rb
    lib/cloudapp/collection_json.rb
    lib/cloudapp/collection_json/collection.rb
    lib/cloudapp/collection_json/item.rb
    lib/cloudapp/collection_json/template.rb
    lib/cloudapp/credentials.rb
    lib/cloudapp/service.rb
    man/cloudapp.1
    man/cloudapp.1.html
    man/cloudapp.1.ronn
    script/docs
    spec/cloudapp/authorized_spec.rb
    spec/cloudapp/collection_json/collection_spec.rb
    spec/cloudapp/collection_json/item_spec.rb
    spec/cloudapp/collection_json/template_spec.rb
    spec/cloudapp/credentials_spec.rb
    spec/helper.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  # s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
