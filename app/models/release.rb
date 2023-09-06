require 'open-uri'

class Release < ApplicationRecord
  include Styles
  include Ripped

  validates :data, presence: true
  has_many :user_releases, dependent: :destroy
  has_many :users, through: :user_releases
  has_one_attached :photo

  after_create :add_date
  after_create :check_if_ripped_on_discogs
  after_create :download_photo

  scope :sorted_by_date_added, -> { order('date_added DESC') }
  scope :to_rip, -> { where(rip_later?: true, ripped: false) }

  self.per_page = 50

  def add_date
    update(date_added: data["date_added"].to_time)
  end

  def download_photo
    # exit if there is no data or if there is already a photo
    return if data.nil? || photo.attached?

    url = data["basic_information"]["cover_image"]
    file = URI.open(url)
    photo.attach(io: file, filename: "#{data["basic_information"]["title"]}.jpg", content_type: 'image/jpeg')
  end
end
