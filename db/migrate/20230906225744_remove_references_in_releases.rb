class RemoveReferencesInReleases < ActiveRecord::Migration[7.0]
  def change
    remove_reference :releases, :user, foreign_key: true
  end
end
