class ReleasesController < ApplicationController
  before_action :set_release, only: %i[edit update ripped]

  def index
    # does user has a collection ?
    return redirect_to authenticate_path if current_user.collection.nil?
    # is the collection synced?
    # sync_collection unless session[:sync] == true

    # filter different params
    @releases = Release.sorted_by_date_added
    @releases = @releases.filtered_by_ripped if params[:ripped].present?
    #paginate
    @releases = @releases.page(params[:page])
    #
    # all.sort_by {|el| el.data["date_added"].to_time}
  end

  def ripped
    @release.ripped ? change_rip = false : change_rip = true
    if @release.update(ripped: change_rip)
      wrapper  = current_user.authentify_wrapper(current_user.access_token)
      if change_rip == true
        @release.ripped_on_discogs!(wrapper, current_user.username, "1", @release.id.to_s, @release.data["instance_id"].to_s, "3", {value: 'RIP ok'})
      elsif change_rip == false
        @release.ripped_on_discogs!(wrapper, current_user.username, "1", @release.id.to_s, @release.data["instance_id"].to_s, "3", {value: ''})
      end
      redirect_to releases_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_release
    @release = Release.find(params[:id])
  end

  def release_params
    params.require(:release).permit(:data, :user_id, :ripped)
  end

  def sync_collection
    # compare and check if new items have been added to the collection
    fetched_collection = FetchMoreCollectionJob.perform_now(current_user.id)
    return if current_user.collection.length >= fetched_collection.length
    # SaveCollectionJob.perform_now(fetched_collection, current_user.id)
    flash.alert = "consider syncing your collection"
    session[:sync] = true
  end
end
