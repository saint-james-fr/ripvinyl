class SaveCollectionJob < ApplicationJob
  queue_as :default

  def perform(collection, id)
    puts '****** STARTS JOB *******'
    # retrieve user with id
    user = User.find(id)
    wrapper = user.authentify_wrapper(user.access_token)
    # For each release of collection parameter
    collection.each do |release|
      # Create new reference in DB OR find if it exists
      item = Release.find_or_create_by(id: release["id"], user: user)
      # Update reference with data
      item.update(data: release) if item.data.nil?
    end
    # Update status of collection? boolean
    user.save_collection!
    puts '****** JOB DONE *******'
    puts "#{user.username} collection saved? == #{user.collection?}"
    puts '****** SEE YOU LATER *******'
  end
end
