class FetchMoreCollectionJob < ApplicationJob
  queue_as :default
  include DiscogsRequests

  def perform(id)
    # Initalize variables
    user = User.find(id)
    wrapper = user.authentify_wrapper(user.access_token)
    number_of_pages = wrapper.get_user_collection(user.username, { per_page: 500 }).pagination.pages

    # Gets pages as an array
    pages = (1..number_of_pages).to_a
    # Iterates over the array and fetch array of releases for each page
    data = pages.map do |page_number|
      wrapper.get_user_collection(user.username, { per_page: 500, page: page_number }).releases
    end
    # Transforms this array of arrays into one array and assigns it to collection
    return data.reduce([], :concat)
  end
end
