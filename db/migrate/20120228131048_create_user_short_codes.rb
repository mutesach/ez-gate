class CreateUserShortCodes < ActiveRecord::Migration
  def change
    create_table :user_short_codes do |t|
      t.column :user_id, :integer, :null => false
			t.column :short_code_id, :integer, :null => false
      t.timestamps
    end
  end
end
