class CreateShortCodes < ActiveRecord::Migration
  def change
    create_table :short_codes do |t|
      t.column :code, :string, :limit => 20, :null => false
			t.column :smsc, :string, :limit => 20, :null => false
			t.column :sms_cost, :integer, :null => true
			t.column :status, :boolean, :null => false, :default => false
      t.timestamps
    end
    add_index :short_codes, :code, :name => "idx_short_codes_code"
		add_index :short_codes, :smsc, :name => "idx_short_codes_smsc"
  end
end
