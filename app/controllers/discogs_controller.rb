class DiscogsController < ApplicationController
  include DiscogsRequests


  def authenticate
    return redirect_to root_path if current_user.access_token.present?
    @wrapper = Discogs::Wrapper.new("Ripped Vinyl")
    request_data = @wrapper.get_request_token(ENV['DISCOGS_API_CONSUMER'],ENV['DISCOGS_API_SECRET'], "http://127.0.0.1:3000/callback")
    session[:request_token] = request_data[:request_token]
    redirect_to request_data[:authorize_url], allow_other_host: true
  end

  def callback
    return redirect_to error_path unless params[:denied].nil?

    @wrapper = Discogs::Wrapper.new("Ripped Vinyl")
    user = current_user
    request_token = session[:request_token]
    verifier = params[:oauth_verifier]
    session[:access_token] = @wrapper.authenticate(request_token, verifier)
    # Empties part of the cache
    session[:request_token] = nil
    user.access_token = session[:access_token]
    @wrapper = user.authentify_wrapper(session[:access_token])
    user.update_username
    redirect_to root_path
  end

  def collection
    user = current_user
    wrapper = user.authentify_wrapper(session[:access_token])
    username = user.username

    @collection = request_collection(wrapper, username)

  render json: @collection
  end
end