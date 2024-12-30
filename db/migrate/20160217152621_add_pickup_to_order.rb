class AddPickupToOrder < ActiveRecord::Migration[4.2]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:orders, :pickup)    
      add_column :orders, :pickup, :date
    end
  end
end
