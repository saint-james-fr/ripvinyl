class SaveCollectionJob < ApplicationJob
  queue_as :default

  def perform(releases, user_id)
    puts '****** STARTS JOB *******'

    begin
      # Retrieves user with user_id
      current_user = User.find(user_id)

      ActiveRecord::Base.transaction do
        # Batch processing and bulk insert
        releases.each_slice(100) do |batch_releases|
          UserRelease.insert_all(batch_releases.map { |release| { user_id: current_user.id, release_id: release["id"] } })
          Release.insert_all(batch_releases.map { |release| { id: release["id"], data: release } })
        end

        # Collection? => true
        current_user.save_collection!
      end

      puts '****** JOB DONE *******'
      puts "#{current_user.username} collection saved? == #{current_user.collection?}"
      puts '****** SEE YOU LATER *******'

    rescue StandardError => e
      # Handle any errors that occur during the job execution
      puts '****** ERROR OCCURRED *******'
      puts "Error message: #{e.message}"
      puts '****** SEE YOU LATER *******'

      # You may also want to log the error or notify administrators here.
    end
  end
end
