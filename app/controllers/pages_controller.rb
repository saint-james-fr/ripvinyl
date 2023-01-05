class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]
  include DiscogsRequests

  def home
    # does user has a token? Go to '/authenticate'
    return redirect_to authenticate_path if current_user.access_token.nil?

    # user already has a collection ? Go to '/releases'
    return redirect_to releases_path if current_user.collection?

    render "pages/home"
    # Fetch the collection and save it, then go to '/releases'
    fetched_collection = FetchMoreCollectionJob.perform_now(current_user.id)
    SaveCollectionJob.perform_now(fetched_collection, current_user.id)
    redirect_to releases_path
  end

  def error
  end

end
