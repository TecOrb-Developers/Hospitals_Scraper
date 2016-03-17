class CreateInvalidStateUrls < ActiveRecord::Migration
  def change
    create_table :invalid_state_urls do |t|
      t.string :url

      t.timestamps null: false
    end
  end
end
