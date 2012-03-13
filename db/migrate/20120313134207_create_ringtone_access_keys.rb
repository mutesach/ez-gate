class CreateRingtoneAccessKeys < ActiveRecord::Migration
  def change
    create_table :ringtone_access_keys do |t|

      t.timestamps
    end
  end
end
