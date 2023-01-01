class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :releases

  encrypts :oauth_token
  encrypts :oauth_token_secret
  encrypts :oauth_token_consumer

  # OAuth::AccessToken persistance for jobs

  def access_token=(value)
    update(oauth_token: value.token)
    update(oauth_token_secret: value.secret)
    # Serialize Consumer OAuth Object
    update(oauth_token_consumer: value.consumer.to_json)
  end

  def access_token
    return nil if oauth_token.nil? || oauth_token.empty?

    # Reserialize data
    consumer_data = JSON.parse(self.oauth_token_consumer)
    # Recreates consumer OAuth objects
    consumer = OAuth::Consumer.new(consumer_data["key"], consumer_data["secret"], consumer_data["options"])
    # Return Access Token
    OAuth::AccessToken.new(consumer, self.oauth_token, self.oauth_token_secret)
  end

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

  #

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
