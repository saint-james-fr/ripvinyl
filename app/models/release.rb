require 'open-uri'

class Release < ApplicationRecord
  validates :data, presence: true
  belongs_to :user
  has_one_attached :photo

  after_create :set_date_added
  after_create :update_ripped_based_on_discogs
  after_create :set_url
  after_create :download_photo

  scope :ripped, -> { where(ripped: true) }
  scope :sorted_by_date_added, -> { order(:date_added).reverse_order}
  scope :filtered_by_ripped, -> {where(ripped: true)}

  # scope :sorted_by_artist, -> { order("data->>'artist' ASC") }
  # scope :sorted_by_title, -> { order("data->>'title' ASC") }
  # scope :sorted_by_label, -> { order("data->>'label' ASC") }
  # scope :sorted_by_format, -> { order("data->>'format' ASC") }
  # scope :sorted_by_country, -> { order("data->>'country' ASC") }
  # scope :sorted_by_genre, -> { order("data->>'genre' ASC") }
  # scope :sorted_by_style, -> { order("data->>'style' ASC") }
  # scope :sorted_by_catno, -> { order("data->>'catno' ASC") }
  # scope :sorted_by_type, -> { order("data->>'type' ASC") }
  # scope :sorted_by_status, -> { order("data->>'status' ASC") }
  # scope :sorted_by_year, -> { order("data->>'year' ASC") }
  # scope :sorted_by_rating, -> { order("data->>'rating' ASC") }
  # scope :sorted_by_notes, -> { order("data->>'notes' ASC") }
  # scope :sorted_by_master_id, -> { order("data->>'master_id' ASC") }
  # scope :sorted_by_instance_id, -> { order("data->>'instance_id' ASC") }
  # scope :sorted_by_resource_url, -> { order("data->>'resource_url' ASC") }
  # scope :sorted_by_uri, -> { order("data->>'uri' ASC") }
  # scope :sorted_by_thumb, -> { order("data->>'thumb' ASC") }
  # scope :sorted_by_cover_image, -> { order("data->>'cover_image' ASC") }
  # scope :sorted_by_community, -> { order("data->>'community' ASC") }
  # scope :sorted_by_data_quality, -> { order("data->>'data_quality' ASC") }
  # scope :sorted_by_format_quantity, -> { order("data->>'format_quantity' ASC") }
  # scope :sorted_by_id, -> { order("data->>'id' ASC") }
  # scope :sorted_by_master_url, -> { order("data->>'master_url' ASC") }
  # scope :sorted_by_title,

  self.per_page = 150

  def set_date_added
    update(date_added: data["date_added"].to_time)
  end

  # Take care of URL

  def set_url
    rebuild_url if direct_url == "#" || direct_url.nil?
  end

  def rebuild_url
    # regex to remove parenthesis and add hyphens
    first_artist_name = data["basic_information"]["artists"].first["name"].gsub(/\s\(\d\)/,'').gsub(" ", "-")
    # regex to join artists with second artist eventually or title
    first_join = data["basic_information"]["artists"].first["join"].gsub(" ", "-")
    first_join == '' ? first_join = '-' : first_join + '-'
    artists_infos = first_artist_name + first_join
    # if there is a second artist, add it to the string
    if data["basic_information"]["artists"] == 2
      second_artist_name = data["basic_information"]["artists"][1]["name"].gsub(/\s\(\d\)/, '').gsub(" ", "-")
      second_join = data["basic_information"]["artists"][1]["join"].gsub(" ", "-")
      second_join == '' ? second_join = '-' : second_join += '-'
      artists_infos += (second_artist_name + second_join)
    end
    # regex to format title
    title = data["basic_information"]["title"].gsub(" ", "-").gsub("/", "").gsub('--','-')

    rebuilt_url = "https://www.discogs.com/release/#{id}-#{artists_infos}#{title}"
    update(direct_url: rebuilt_url)
  end

  def photo?
    photo.attached?
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
    return unless data.nil? || photo?

    url = data["basic_information"]["cover_image"]
    file = URI.open(url)
    photo.attach(io: file, filename: "#{data["basic_information"]["title"]}.jpg", content_type: 'image/jpg')
  end
end
