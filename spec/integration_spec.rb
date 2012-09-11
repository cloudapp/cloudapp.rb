require 'helper'
require 'support/vcr'

require 'cloudapp'

describe CloudApp, :integration do
  let(:path) { Pathname('../support/files/favicon.ico').expand_path(__FILE__) }

  it 'integrates with the API' do
    token = CloudApp::Service.token_for_account 'arthur@dent.com', 'towel'
    token.should =~ /\w+/

    service = CloudApp::Service.using_token token
    service.drops(filter: 'all').each(&:delete)
    service.drops(filter: 'all').should be_empty

    bookmark    = service.bookmark('http://getcloudapp.com', name: 'CloudApp').first
    file        = service.upload(path).first
    public_drop = service.bookmark('http://getcloudapp.com', private: false).first

    service.drops(filter: 'all').should have(3).items

    bookmark_details = service.drop(bookmark.href).first
    bookmark_details.name   .should eq('CloudApp')
    bookmark_details.should be_private

    file_details = service.drop(file.href).first
    file_details.name   .should eq('favicon.ico')
    file_details.should be_private

    public_drop_details = service.drop(public_drop.href).first
    public_drop_details.name   .should eq('http://getcloudapp.com')
    public_drop_details.should be_public

    file = file.toggle_privacy.first
    file.should be_public
    file = file.toggle_privacy.first
    file.should be_private

    bookmark.trash
    file    .trash
    service.drops(filter: 'all')   .should have(3).items
    service.drops(filter: 'active').should have(1).item
    service.drops(filter: 'trash') .should have(2).items

    bookmark.recover
    service.drops(filter: 'all')   .should have(3).items
    service.drops(filter: 'active').should have(2).item
    service.drops(filter: 'trash') .should have(1).items

    page1 = service.drops(filter: 'all', limit: 1)
    page1.should have(1).item

    page2 = page1.follow 'next'
    page2.should have(1).item

    page3 = page2.follow 'next'
    page3.should have(1).item
    page3.should_not have_link('next')

    page2 = page3.follow 'previous'
    page2.should have(1).item

    page1 = page2.follow 'previous'
    page1.should have(1).item
    page1.should_not have_link('previous')

    page1 = page3.follow 'first'
    page1.should have(1).item
    page1.should_not have_link('previous')

    bookmark   .delete
    file       .delete
    public_drop.delete
    service.drops(filter: 'all').should be_empty
  end
end
