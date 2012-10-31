class AddAverageFee < ActiveRecord::Migration
  def up
    add_column :banks, :average_fee, :float
  end

  def down
    remove_column :banks, :average_fee
  end
end
