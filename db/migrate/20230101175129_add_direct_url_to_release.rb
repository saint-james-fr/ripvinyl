class AddDirectUrlToRelease < ActiveRecord::Migration[7.0]
  def change
    add_column :releases, :direct_url, :string
  end
end
