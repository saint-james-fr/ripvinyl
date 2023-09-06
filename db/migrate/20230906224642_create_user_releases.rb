class CreateUserReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :user_releases do |t|
      t.references :user, foreign_key: true
      t.references :release, foreign_key: true
      t.timestamps
    end
  end
end
