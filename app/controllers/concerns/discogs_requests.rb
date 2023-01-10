module DiscogsRequests
  extend ActiveSupport::Concern

  def request_user_informations(wrapper, username)
    wrapper.get_user(username)
  end

  def request_collection(wrapper, username, items_per_page = 50)
    wrapper.get_user_collection(username, { per_page: items_per_page })
  end

  def ripped_on_discogs_bis?(release)
    # is there data? is there notes? is there a field for 'RIP notes' and is it empty?
    return false if release["notes"].nil? || release["notes"].select {|el| el["field_id"] == 3}.empty?

    release["notes"].select {|el| el["field_id"] == 3}[0]["value"].match?(/rip/i)
  end

end
