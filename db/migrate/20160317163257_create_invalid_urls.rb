class CreateInvalidUrls < ActiveRecord::Migration
  def change
    create_table :invalid_urls do |t|
      t.string :url

      t.timestamps null: false
    end
  end
end
