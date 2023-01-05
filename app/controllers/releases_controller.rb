class ReleasesController < ApplicationController
  before_action :set_release, only: %i[edit update ripped]
  before_action :clause_guard_collection, only: %i[index four_to_the_floor]

  def index
    # filter different params
    @releases = Release.sorted_by_date_added
    @releases = @releases.ripped if params[:ripped] == "true"
    @releases = @releases.filtered_by_style(params[:style]) if params[:style].present?
    # paginate
    @releases = @releases.page(params[:page])
    @most_collected_styles = Release.most_collected_styles

  end

  def four_to_the_floor
    ids = Release.sorted_by_date_added.sample(4).pluck(:id)
    @releases = Release.where(id: ids)
    @releases = @releases.page(params[:page])
    @most_collected_styles = []
  end

  def update_collection
    user = User.find(params[:id])
    # Fetch collection from Discogs
    fetched_collection = FetchMoreCollectionJob.perform_now(user.id)
    # Get array of releases's id already in DB
    ids = Release.where(user: user).pluck(:id)
    # Reject existing releases from fetched collection
    new_items = fetched_collection.reject { |release| ids.include?(release["id"]) }
    # Save the new releases in DB
    SaveCollectionJob.perform_now(new_items, user.id) if new_items.any?
    # Get removed releases
    removed_items = ids.reject { |id| fetched_collection.any? { |release| release["id"] == id } }
    # Delete the removed releases from DB
    Release.where(id: removed_items).destroy_all if removed_items.any?
    respond_to do |format|
      format.html { redirect_to releases_path }
    end
  end

  def ripped
    new_ripped = !@release.ripped
    if @release.update(ripped: new_ripped)
      wrapper = current_user.authentify_wrapper(current_user.access_token)
      case new_ripped
      when true
        @release.ripped_on_discogs!(wrapper, current_user.username, "1", @release.id.to_s, @release.data["instance_id"].to_s, "3", {value: 'RIP ok'})
      when false
        @release.ripped_on_discogs!(wrapper, current_user.username, "1", @release.id.to_s, @release.data["instance_id"].to_s, "3", {value: ''})
      end
      redirect_to releases_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def clause_guard_collection
    return redirect_to authenticate_path if current_user.collection.nil?
  end

  def set_release
    @release = Release.find(params[:id])
  end

  def release_params
    params.require(:release).permit(:data, :user_id, :ripped)
  end

end
