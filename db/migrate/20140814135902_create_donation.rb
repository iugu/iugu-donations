class CreateDonation < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.string :email
      t.integer :amount_cents
      t.timestamps
    end
  end
end
