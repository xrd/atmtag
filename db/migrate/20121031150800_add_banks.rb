class AddBanks < ActiveRecord::Migration
  def up
    create_table :banks do |t|
      t.timestamps
      t.string :name, :state, :country
    end

    create_table :fees do |t|
      t.timestamps
      t.integer :user_id
      t.float :fee
      t.string :currency
    end
  end

  def down
    drop_table :banks, :fees
  end
end
