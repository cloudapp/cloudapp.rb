require 'helper'
require 'support/vcr'

require 'cloudapp'

describe CloudApp, :integration do
  let(:path) { Pathname('../support/files/favicon.ico').expand_path(__FILE__) }

  def all_drops(options = {})
    options = { filter: 'all' }.merge(options)
    @account.drops(options)
  end

  def active_drops
    @account.drops(filter: 'active')
  end

  def trashed_drops
    @account.drops(filter: 'trash')
  end

  def create_bookmark(url, options = {})
    @account.bookmark(url, options).first
  end

  def create_upload(path, options = {})
    @account.upload(path, options).first
  end

  def drop_details(drop)
    @account.drop_at(drop.href).first
  end

  def recover_drop(drop)
    @account.recover_drop(drop.href).first
  end

  def trash_drop(drop)
    @account.trash_drop(drop.href).first
  end

  def delete_drop(drop)
    @account.delete_drop(drop.href)
  end


  it 'integrates with the API' do
    token = CloudApp::Token.for_account 'arthur@dent.com', 'towel'
    token.should_not be_nil

    @account = CloudApp::Account.using_token token
    drops    = all_drops
    unless all_drops.empty?
      drops.each do |drop| delete_drop(drop) end
    end

    all_drops.should be_empty

    bookmark    = create_bookmark 'http://getcloudapp.com', name: 'CloudApp'
    file        = create_upload   path
    public_drop = create_bookmark 'http://getcloudapp.com', private: false

    all_drops.should have(3).items

    bookmark_details = drop_details bookmark
    bookmark_details.name   .should eq('CloudApp')
    bookmark_details.private.should eq(true)

    drop_details(file).name.should eq('favicon.ico')
    drop_details(public_drop).private.should eq(false)

    trash_drop bookmark
    trash_drop file
    all_drops    .should have(3).items
    active_drops .should have(1).items
    trashed_drops.should have(2).items

    recover_drop bookmark
    all_drops    .should have(3).items
    active_drops .should have(2).items
    trashed_drops.should have(1).items

    limited = all_drops(limit: 1)
    limited.should have(1).item

    next_page = all_drops(href: limited.link('next').href)
    next_page.should have(1).item

    # TODO: Uncomment when pagination with filter is fixed.
    next_page = all_drops(href: next_page.link('next').href)
    next_page.should have(1).item
    next_page.link('next') { nil }.should be_nil

    delete_drop bookmark
    delete_drop file
    delete_drop public_drop

    all_drops.should have(0).items
  end
end
