module CloudApp
  module CollectionJson
    Tint = Leadlight::Tint.new 'collection+json', status: [ :success, 401 ] do
      match_content_type 'application/vnd.collection+json'
      extend CollectionJson::Representation
      collection_links.each do |link|
        add_link link.href, link.rel
      end
    end
  end
end
