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
  s.name              = 'cloudapp-service'
  s.version           = '1.0.0.beta.1'
  s.date              = '2012-10-08'
  s.rubyforge_project = 'cloudapp-service'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "CloudApp API Client"
  s.description = "CloudApp API Client"

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Larry Marburger"]
  s.email    = 'larry@marburger.cc'
  s.homepage = 'https://github.com/cloudapp/cloudapp.rb'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md MIT-LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency 'leadlight', '~> 0.0.7'
  s.add_dependency 'typhoeus',  '~> 0.3.3'

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'vcr', '~> 2.0.0'
  s.add_development_dependency 'webmock'

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    Gemfile
    Gemfile.lock
    MIT-LICENSE
    README.md
    Rakefile
    cloudapp-service.gemspec
    lib/cloudapp/collection_json.rb
    lib/cloudapp/collection_json/item.rb
    lib/cloudapp/collection_json/representation.rb
    lib/cloudapp/collection_json/template.rb
    lib/cloudapp/collection_json/tint.rb
    lib/cloudapp/service.rb
    lib/cloudapp/service/authorized_representation.rb
    lib/cloudapp/service/drop.rb
    lib/cloudapp/service/drop_collection.rb
    spec/cassettes/account_token.yml
    spec/cassettes/create_bookmark.yml
    spec/cassettes/create_bookmark_with_name.yml
    spec/cassettes/create_bookmark_with_privacy.yml
    spec/cassettes/delete_drop.yml
    spec/cassettes/list_drops.yml
    spec/cassettes/list_drops_with_bad_token.yml
    spec/cassettes/list_drops_with_filter.yml
    spec/cassettes/list_drops_with_limit.yml
    spec/cassettes/privatize_drop.yml
    spec/cassettes/publicize_drop.yml
    spec/cassettes/purge_drops.yml
    spec/cassettes/recover_drop.yml
    spec/cassettes/rename_drop.yml
    spec/cassettes/token_for_account.yml
    spec/cassettes/token_for_account_with_bad_credentials.yml
    spec/cassettes/trash_drop.yml
    spec/cassettes/update_drop_bookmark_url.yml
    spec/cassettes/update_file.yml
    spec/cassettes/upload_file.yml
    spec/cassettes/upload_file_with_name.yml
    spec/cassettes/upload_file_with_privacy.yml
    spec/cassettes/view_drop.yml
    spec/cloudapp/authorized_representation_spec.rb
    spec/cloudapp/collection_json/item_spec.rb
    spec/cloudapp/collection_json/representation_spec.rb
    spec/cloudapp/collection_json/template_spec.rb
    spec/cloudapp/drop_collection_spec.rb
    spec/cloudapp/drop_spec.rb
    spec/cloudapp/service_spec.rb
    spec/helper.rb
    spec/integration_spec.rb
    spec/support/files/favicon.ico
    spec/support/stub_class_or_module.rb
    spec/support/vcr.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  # s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
