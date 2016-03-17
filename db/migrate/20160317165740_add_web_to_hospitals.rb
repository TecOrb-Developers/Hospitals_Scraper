class AddWebToHospitals < ActiveRecord::Migration
  def change
    add_column :hospitals, :web, :string
  end
end
