class CreateGsaRates < ActiveRecord::Migration
  def change
    create_table :gsa_rates do |t|
      t.string :state
      t.string :primary_destination
      t.string :county
      t.string :jan
      t.string :feb
      t.string :mar
      t.string :apr
      t.string :may
      t.string :jun
      t.string :jul
      t.string :aug
      t.string :sep
      t.string :oct
      t.string :nov
      t.string :dec
      t.string :mim

      t.timestamps null: false
    end
  end
end
