class ReleasesController < ApplicationController
  before_action :set_release, only: %i[edit update ripped]

  def index
    # does user has a collection ?
    return redirect_to authenticate_path if current_user.collection.nil?

    # is the collection synced?

    # perform a paginated query:
    @releases = Release.paginate(page: params[:page])
  end

  def ripped
    @release.ripped ? change_rip = false : change_rip = true
    if @release.update(ripped: change_rip)
      redirect_to releases_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @release.update(release_params)
      format.html { redirect_to release_url(@release), notice: "Release was successfully updated." }
    else
      format.html { render :edit, status: :unprocessable_entity }
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

    SaveCollectionJob.perform_now(fetched_collection, current_user.id)
  end
end
