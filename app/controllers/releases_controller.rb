class ReleasesController < ApplicationController
  before_action :set_release, only: %i[edit update ripped rip_later]
  before_action :clause_guard_collection, only: %i[index four_to_the_floor]

  include DiscogsRequests

  def index
    # filter different params
    @releases = Release.sorted_by_date_added
    @releases = @releases.ripped if params[:ripped] == "true"
    @releases = @releases.to_rip if params[:rip_later?] == "true"
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
    p "*****"
    p "****** FETCHING COLLECTION *******"
    fetched_collection = FetchMoreCollectionJob.perform_now(user.id)
    p "*****"
    p "****** FETCHING COLLECTION DONE *******"
    p "*****"
    # Get array of ID from releases already in DB
    release_ids = Release.pluck(:id)
    # 1. get new releases and save them
    p "*****"
    p "****** SAVING NEW RELEASES *******"
    save_added_releases(user, fetched_collection, release_ids)
    p "*****"
    p "****** SAVING NEW RELEASES DONE *******"
    p "*****"
    # 2. Get removed releases and delete them
    p "*****"
    p "****** GETTING REMOVED RELEASES *******"
    remove_removed_releases(fetched_collection, release_ids)
    p "*****"
    p "****** GETTING REMOVED RELEASES DONE *******"
    p "*****"
    # 3. Update releases in DB from their discogs status
    p "*****"
    p "****** UPDATING RELEASES *******"
    update_ripped_releases(fetched_collection, user)
    p "*****"
    p "****** UPDATING RELEASES DONE *******"
    p "*****"

    respond_to do |format|
      format.html { redirect_to releases_path }
    end
  end

  def ripped
    new_ripped = !@release.ripped
    if @release.update(ripped: new_ripped)
      # if we rip the release then we remove it from the rip_later list
      @release.rip_later if new_ripped == true
      wrapper = current_user.authentify_wrapper(current_user.access_token)
      case new_ripped
      when true
        @release.ripped_on_discogs!(wrapper, current_user.username, "1", @release.id.to_s, @release.data["instance_id"].to_s, "3", { value: "RIP ok" })
      when false
        @release.ripped_on_discogs!(wrapper, current_user.username, "1", @release.id.to_s, @release.data["instance_id"].to_s, "3", { value: "" })
      end
      redirect_to releases_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  def rip_later
    @release.rip_later
  end

  private

  def save_added_releases(user, fetched_collection, ids)
    new_items = fetched_collection.reject { |release| ids.include?(release["id"]) }
    SaveCollectionJob.perform_now(new_items, user.id) if new_items.any?
  end

  def remove_removed_releases(fetched_collection, ids)
    removed_items = ids.reject { |id| fetched_collection.any? { |release| release["id"] == id } }
    Release.where(id: removed_items).destroy_all if removed_items.any?
  end

  def update_ripped_releases(fetched_collection, user)
    fetched_collection.each do |release|
      Release.where(user: user).find(release["id"]).update(ripped: true) if ripped_on_discogs_bis?(release)
    end
  end

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
