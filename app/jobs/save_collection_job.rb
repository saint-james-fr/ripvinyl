class SaveCollectionJob < ApplicationJob
  queue_as :default

  def perform(releases, user_id)
    puts '****** STARTS JOB *******'
    # retrieves user with user_id
    user = User.find(user_id)
    # For each release of releases parameter...
    releases.each do |release|
      # Create new reference in DB
      Release.create(id: release["id"], user: user, data: release)
    end
    # collection? => true
    user.save_collection!
    puts '****** JOB DONE *******'
    puts "#{user.username} collection saved? == #{user.collection?}"
    puts '****** SEE YOU LATER *******'
  end
end
