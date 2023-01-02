class SaveCollectionJob < ApplicationJob
  queue_as :default

  def perform(releases, user_id)
    puts '****** STARTS JOB *******'
    # retrieves user with user_id
    current_user = User.find(user_id)
    # For each release of releases parameter...
    releases.each do |release|
      # Create new reference in DB
      Release.find_or_create_by(id: release["id"], user: current_user) do |item|
        item.data = release
      end
    end
    # collection? => true
    current_user.save_collection!
    puts '****** JOB DONE *******'
    puts "#{current_user.username} collection saved? == #{current_user.collection?}"
    puts '****** SEE YOU LATER *******'
  end
end
