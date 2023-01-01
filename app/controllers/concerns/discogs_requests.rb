module DiscogsRequests
  extend ActiveSupport::Concern

  def request_user_informations(wrapper, username)
    wrapper.get_user(username)
  end

  def request_collection(wrapper, username, items_per_page = 50)
    wrapper.get_user_collection(username, { per_page: items_per_page })
  end

end
