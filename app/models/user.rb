class User < ApplicationRecord
  include Token
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  has_many :releases

  # Discogs::Wrapper

  def authentify_wrapper(token)
    return nil if token.nil?

    @wrapper = Discogs::Wrapper.new("Collection", access_token: token)
  end

  # Username

  def username?
    !username.nil? && !username.empty?
  end

  def update_username
    update(username: @wrapper.get_identity.username) unless username? == true
  end

  # Collection

  def save_collection!
    update(collection?: true)
  end

  def collection
    releases
  end

  def retrieve_collection
    releases.map { |release| release.data} unless collection.nil?
  end

end
