class CreateOutboundMessages < ActiveRecord::Migration
  def change
    create_table :outbound_messages do |t|
      t.column :user_id, :integer, :null => false
			t.column :inbound_id, :integer, :null => true
			t.column :service, :string, :limit => 10, :null => false
			t.column :sender, :string, :limit => 15, :null => false
			t.column :destination, :string, :limit => 15, :null => false
			t.column :content, :string, :limit => 170, :null => false
			t.column :status, :string, :limit => 15
			t.column :status_message, :string, :limit => 50, :default => ""
      t.timestamps
    end
    add_index :outbound_messages, :user_id, :name => "idx_outbound_messages_user_id"
    add_index :outbound_messages, :inbound_id, :name => "idx_outbound_messages_incoming_id"
		add_index :outbound_messages, :service, :name => "idx_outbound_messages_service"
		add_index :outbound_messages, :sender, :name => "idx_outbound_messages_sender"
		add_index :outbound_messages, :destination, :name => "idx_outbound_messages_destination"
  end
end
