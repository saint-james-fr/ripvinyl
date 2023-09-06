class DownloadPhotoJob < ApplicationJob
  queue_as :default

  # Define the maximum number of retries
  MAX_RETRIES = 3

  def perform(releases)
    puts '****** STARTS JOB *******'

    releases.each do |release|
      retry_count = 0

      begin
        response = release.download_photo
        sleep 0.3
      rescue StandardError => e
        # Handle the error and retry if within the maximum retry count
        if retry_count < MAX_RETRIES
          retry_count += 1
          puts "Error occurred while downloading photo for release #{release.id}. Retrying (attempt #{retry_count})..."
          retry
        else
          puts "Max retry count reached for release #{release.id}. Error message: #{e.message}"
          # Handle further error handling or logging here
        end
      end

      # Log the response headers
    end

    puts '****** JOB COMPLETED *******'
  end

end
