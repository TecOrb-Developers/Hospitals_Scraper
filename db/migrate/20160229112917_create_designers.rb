class CreateDesigners < ActiveRecord::Migration
  def change
    create_table :designers do |t|
      t.string :name
      t.string :contact
      t.string :email
      t.string :address
      t.string :state
      t.string :pin

      t.timestamps null: false
    end
  end
end
