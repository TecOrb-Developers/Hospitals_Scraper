class CreateHospitals < ActiveRecord::Migration
  def change
    create_table :hospitals do |t|
      t.string :name
      
      t.string :address
      t.string :city
      t.string :pin
      t.string :state
      t.string :country
      t.string :contact
      t.string :fax
      t.string :link
      t.string :trauma_center
      t.string :hospital_type
      t.string :beds
      t.string :ranking, array: true, default: []
      t.string :specialties, array: true, default: []
      t.text :description

      t.timestamps null: false
    end
  end
end
