class FetchMoreCollectionJob < ApplicationJob
  queue_as :default
  include DiscogsRequests

  def perform(id)
    # Initalize variables
    user = User.find(id)
    wrapper = user.authentify_wrapper(user.access_token)
    number_of_pages = wrapper.get_user_collection(user.username, { per_page: 100 }).pagination.pages

    # Gets pages as an array
    pages = (1..number_of_pages).to_a
    # Iterates over the array and fetch array of releases for each page
    data = pages.map do |page_number|
      wrapper.get_user_collection(user.username, { per_page: 100, page: page_number }).releases
    end
    raise "Error while fetching collection from Discogs. Some data nil? #{data.include?(nil)}}" if data.include?(nil)

    # Transforms this array of arrays into one array and returns it
    return data.reduce([], :concat)

  end
end
