require 'open-uri'

class Release < ApplicationRecord
  validates :data, presence: true
  belongs_to :user
  has_one_attached :photo

  after_create :set_date_added
  after_create :update_ripped_based_on_discogs
  after_create :download_photo

  scope :ripped, -> { where(ripped: true) }
  scope :sorted_by_date_added, -> { order('date_added DESC') }
  scope :filtered_by_ripped, -> {where(ripped: true)}

  self.per_page = 150

  def styles
    data["basic_information"]["styles"]
  end

  def self.filtered_by_style(style)
    where(id: all.select{ |release| release.styles.include? style })
  end

  def self.most_collected_styles
    styles = all.map { |release| release.styles }
    h = {}
    styles.each do |array|
      array.each do |style|
        h[style].nil? ? h[style] = 1 : h[style] += 1
      end
    end
    return h.sort_by {|k, v| v}.reverse.to_h
  end


  def set_date_added
    update(date_added: data["date_added"].to_time)
  end


  def ripped?
    ripped.present?
  end

  def ripped_on_discogs?
    # is there data? is there notes? is there a field for 'RIP notes' and is it empty?
    return false if data.nil? || data["notes"].nil? || data["notes"].select {|el| el["field_id"] == 3}.empty?


    data["notes"].select {|el| el["field_id"] == 3}[0]["value"].match?(/rip/i)
  end

  def update_ripped_based_on_discogs
    update(ripped: true) if ripped_on_discogs?
  end

  def ripped_on_discogs!(wrapper, username, folder_id, release_id, instance_id, field_id, data = {})
    wrapper.edit_field_on_instance_in_user_folder(username, folder_id, release_id, instance_id, field_id, data)
  end

  def download_photo
    # exit if there is no data or if there is already a photo
    return if data.nil? || photo.attached?

    url = data["basic_information"]["cover_image"]
    file = URI.open(url)
    photo.attach(io: file, filename: "#{data["basic_information"]["title"]}.jpg", content_type: 'image/jpg')
  end
end
