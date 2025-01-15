class AddPaymentToFinancialTransaction < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :financial_transactions, :amount, :decimal, precision: 8, scale: 2, default: nil, null: true
      end
      dir.down do
        change_column :financial_transactions, :amount, :decimal, precision: 8, scale: 2, default: 0, null: false
      end
    end

    add_column :financial_transactions, :updated_on, :timestamp if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :updated_on)
    add_column :financial_transactions, :payment_method, :string if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_method)
    add_column :financial_transactions, :payment_plugin, :string if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_plugin)
    add_column :financial_transactions, :payment_id, :string if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_id)
    add_column :financial_transactions, :payment_amount, :decimal, precision: 8, scale: 3 if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_amount)
    add_column :financial_transactions, :payment_currency, :string if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_currency)
    add_column :financial_transactions, :payment_state, :string if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_state)
    add_column :financial_transactions, :payment_fee, :decimal, precision: 8, scale: 3 if not ActiveRecord::Base.connection.column_exists?(:financial_transactions, :payment_fee)
    add_index :financial_transactions, %i[payment_plugin payment_id] if not ActiveRecord::Base.connection.index_exists?(:financial_transactions, %i[payment_plugin payment_id])
  end
end
