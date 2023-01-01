class AddTokenToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :oauth_token, :text
    add_column :users, :oauth_token_secret, :text
    add_column :users, :oauth_token_consumer, :text
    add_column :users, :collection?, :boolean, default: false
  end
end
