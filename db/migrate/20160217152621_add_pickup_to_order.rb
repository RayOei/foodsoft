class AddPickupToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :pickup, :date if not ActiveRecord::Base.connection.column_exists?(:orders, :pickup)
  end
end
