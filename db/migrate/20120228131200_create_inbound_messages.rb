class CreateInboundMessages < ActiveRecord::Migration
  def change
    create_table :inbound_messages do |t|
      t.column :smsc, :string, :limit => 30, :null => false
			t.column :user_id, :integer, :null => false
			t.column :service_id, :integer, :null => false
			t.column :sender, :string, :limit => 15, :null => false
			t.column :destination, :string, :limit => 15, :null => false
			t.column :content, :string, :limit => 170, :null => false
			t.column :service_status, :string, :limit => 30, :default => "pending"
			t.column :status_message, :string, :limit => 50, :default => ""
			t.column :read_status, :boolean, :default => false
      t.timestamps
    end
    add_index :inbound_messages, :smsc, :name => "idx_inbound_messages_smsc"
		add_index :inbound_messages, :user_id, :name => "idx_inbound_messages_user_id"
		add_index :inbound_messages, :service_id, :name => "idx_inbound_messages_service_id"
		add_index :inbound_messages, :sender, :name => "idx_inbound_messages_sender"
		add_index :inbound_messages, :destination, :name => "idx_inbound_messages_destination"
  end
end
