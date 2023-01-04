require 'open-uri'
require 'release_modules/ripped'
require 'release_modules/styles'

class Release < ApplicationRecord
  include Styles
  include Ripped

  validates :data, presence: true
  belongs_to :user
  has_one_attached :photo

  after_create :add_date
  after_create :update_ripped_based_on_discogs
  after_create :download_photo

  scope :sorted_by_date_added, -> { order('date_added DESC') }

  self.per_page = 150

  def add_date
    update(date_added: data["date_added"].to_time)
  end

  def download_photo
    # exit if there is no data or if there is already a photo
    return if data.nil? || photo.attached?

    url = data["basic_information"]["cover_image"]
    file = URI.open(url)
    photo.attach(io: file, filename: "#{data["basic_information"]["title"]}.jpg", content_type: 'image/jpg')
  end
end
