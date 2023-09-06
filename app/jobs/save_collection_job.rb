class SaveCollectionJob < ApplicationJob
  queue_as :default

  def perform(releases, user_id)
    puts '****** STARTS JOB *******'
    
    # Retrieves user with user_id
    current_user = User.find(user_id)

    # Batch processing and bulk insert
    releases.each_slice(100) do |batch_releases|
      Release.insert_all(batch_releases.map { |release| { id: release["id"], user_id: current_user.id, data: release } })
    end
    
    # Use a transaction for data consistency
    ActiveRecord::Base.transaction do
      releases.each do |release|
        Release.find_or_create_by(id: release["id"], user_id: current_user.id) do |item|
          item.data = release
        end
      end
    end
    
    # Collection? => true
    current_user.save_collection!
    
    puts '****** JOB DONE *******'
    puts "#{current_user.username} collection saved? == #{current_user.collection?}"
    puts '****** SEE YOU LATER *******'
  end
end
