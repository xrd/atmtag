class AddEstimations < ActiveRecord::Migration
  def up
    create_table :estimations do |t|
      t.timestamps
      t.float :lat, :lng
      t.string :name
      t.float :fee
      t.string :uid
      t.integer :user_id
    end
  end

  def down
    drop_table :estimations
  end
end
