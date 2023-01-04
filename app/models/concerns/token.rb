module Token
  extend ActiveSupport::Concern

  included do
    encrypts :oauth_token
    encrypts :oauth_token_secret
    encrypts :oauth_token_consumer
  end

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
end
