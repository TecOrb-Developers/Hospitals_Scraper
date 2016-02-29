class CreateFemaCodes < ActiveRecord::Migration
  def change
    create_table :fema_codes do |t|
      t.string :property_id
      t.string :property_name
      t.string :fema_id
      t.string :address
      t.string :city
      t.string :state
      t.string :state_code
      t.string :state_id
      t.string :pin
      t.string :details
      t.string :phone
      t.string :fax
      t.string :email
      t.string :website

      t.timestamps null: false
    end
  end
end
