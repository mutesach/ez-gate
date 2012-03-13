class CreateMessageStats < ActiveRecord::Migration
  def change
    create_table :message_stats do |t|
      t.column :service,  :string, :limit => 10, :null => false
			t.column :smsc, :string, :limit => 10, :null => false
			t.column :short_code, :string, :limit => 6, :null => false
			t.column :counter, :integer, :null => false
			t.column :message_type, :string, :limit => 5, :null => true
      t.timestamps
    end
    add_index :message_stats, :service, :name => "idx_count_messages_service"
    add_index :message_stats, :smsc, :name => "idx_count_messages_smsc"
    add_index :message_stats, :message_type, :name => "idx_count_messages_message_type"
  end
end
