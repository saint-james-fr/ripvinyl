require 'open-uri'

class Release < ApplicationRecord
  belongs_to :user
  has_one_attached :photo
  before_create :ripped!
  after_update :download_photo

  scope :ripped, -> { where(ripped: true) }

  self.per_page = 50

  # Take care of URL

  def save_rebuild_url
    update(direct_url: rebuild_url)
  end

  def direct_url_or_rebuild
    direct_url == "#" ? rebuild_url : direct_url
  end

  def rebuild_url
    # regex to remove parenthesis and add hyphens
    first_artist_name = data["basic_information"]["artists"].first["name"].gsub(/\s\(\d\)/,'').gsub(" ", "-")
    # regex to join artists with second artist eventually or title
    first_join = data["basic_information"]["artists"].first["join"].gsub(" ", "-")
    first_join == '' ? first_join = '-' : first_join + '-'
    artists_infos = first_artist_name + first_join
    if data["basic_information"]["artists"] == 2
      second_artist_name = data["basic_information"]["artists"][1]["name"].gsub(/\s\(\d\)/, '').gsub(" ", "-")
      second_join = data["basic_information"]["artists"][1]["join"].gsub(" ", "-")
      second_join == '' ? second_join = '-' : second_join += '-'
      artists_infos += (second_artist_name + second_join)
    end
    # regex to format title
    title = release.data["basic_information"]["title"].gsub(" ", "-")

    return "https://www.discogs.com/release/#{release.id}-#{artists_infos}#{title}"
  end


  def photo?
    photo.attached?
  end

  def ripped_on_discogs?
    return false if notes.empty?

    notes.select {|el| el.field_id == 3}[0].value.match(/rip/i)
  end

  def ripped!
    ripped = true if ripped_on_discogs?
  end

  def download_photo
    unless data.nil? || photo?
    url = data["basic_information"]["cover_image"]
    file = URI.open(url)
    photo.attach(io: file, filename: "#{data["basic_information"]["title"]}.jpg", content_type: 'image/jpg')
    sleep(1.0 / 15.0)
    end
  end
end
