class AddRipLaterToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :releases, :rip_later?, :boolean, default: false, null: false
  end
end
