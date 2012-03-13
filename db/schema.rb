# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120307114352) do

  create_table "contacts", :force => true do |t|
    t.integer  "user_id",                  :null => false
    t.integer  "group_id",                 :null => false
    t.string   "name",       :limit => 30, :null => false
    t.string   "phone_no",   :limit => 15, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["group_id"], :name => "fk_contacts_groups"
  add_index "contacts", ["user_id"], :name => "fk_contacts_users"

  create_table "directories", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.string   "directory_ref", :limit => 50,  :null => false
    t.string   "row1",          :limit => 100
    t.string   "row2",          :limit => 100
    t.string   "row3",          :limit => 100
    t.string   "row4",          :limit => 100
    t.string   "row5",          :limit => 100
    t.string   "row6",          :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "directories", ["directory_ref"], :name => "idx_directories_directory_ref"
  add_index "directories", ["user_id"], :name => "idx_directories_user_id"

  create_table "groups", :force => true do |t|
    t.integer  "user_id",                  :null => false
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inbound_messages", :force => true do |t|
    t.string   "smsc",           :limit => 30,                         :null => false
    t.integer  "user_id",                                              :null => false
    t.integer  "service_id",                                           :null => false
    t.string   "sender",         :limit => 15,                         :null => false
    t.string   "destination",    :limit => 15,                         :null => false
    t.string   "content",        :limit => 170,                        :null => false
    t.string   "service_status", :limit => 30,  :default => "pending"
    t.string   "status_message", :limit => 50,  :default => ""
    t.boolean  "read_status",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inbound_messages", ["destination"], :name => "idx_inbound_messages_destination"
  add_index "inbound_messages", ["sender"], :name => "idx_inbound_messages_sender"
  add_index "inbound_messages", ["service_id"], :name => "idx_inbound_messages_service_id"
  add_index "inbound_messages", ["smsc"], :name => "idx_inbound_messages_smsc"
  add_index "inbound_messages", ["user_id"], :name => "idx_inbound_messages_user_id"

  create_table "message_stats", :force => true do |t|
    t.string   "service",      :limit => 10, :null => false
    t.string   "smsc",         :limit => 10, :null => false
    t.string   "short_code",   :limit => 6,  :null => false
    t.integer  "counter",                    :null => false
    t.string   "message_type", :limit => 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_stats", ["message_type"], :name => "idx_count_messages_message_type"
  add_index "message_stats", ["service"], :name => "idx_count_messages_service"
  add_index "message_stats", ["smsc"], :name => "idx_count_messages_smsc"

  create_table "outbound_messages", :force => true do |t|
    t.integer  "user_id",                                       :null => false
    t.integer  "inbound_id"
    t.string   "service",        :limit => 10,                  :null => false
    t.string   "sender",         :limit => 15,                  :null => false
    t.string   "destination",    :limit => 15,                  :null => false
    t.string   "content",        :limit => 170,                 :null => false
    t.string   "status",         :limit => 15
    t.string   "status_message", :limit => 50,  :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outbound_messages", ["destination"], :name => "idx_outbound_messages_destination"
  add_index "outbound_messages", ["inbound_id"], :name => "idx_outbound_messages_incoming_id"
  add_index "outbound_messages", ["sender"], :name => "idx_outbound_messages_sender"
  add_index "outbound_messages", ["service"], :name => "idx_outbound_messages_service"
  add_index "outbound_messages", ["user_id"], :name => "idx_outbound_messages_user_id"

  create_table "ringtones", :force => true do |t|
    t.integer  "user_id",                                       :null => false
    t.string   "keyword",     :limit => 50,                     :null => false
    t.string   "aliases",     :limit => 50
    t.string   "song_title",  :limit => 50
    t.string   "artist_name", :limit => 50
    t.string   "f_name",      :limit => 50
    t.string   "f_extension", :limit => 30
    t.string   "f_size",      :limit => 20
    t.string   "f_path",      :limit => 100
    t.boolean  "status",                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ringtones", ["artist_name"], :name => "idx_ringtones_artist_name"
  add_index "ringtones", ["keyword"], :name => "idx_ringtones_keyword"
  add_index "ringtones", ["song_title"], :name => "idx_ringtones_song_title"
  add_index "ringtones", ["user_id"], :name => "idx_ringtones_user_id"

  create_table "services", :force => true do |t|
    t.string   "name",               :limit => 30,                     :null => false
    t.string   "keyword",            :limit => 10,                     :null => false
    t.string   "aliases",            :limit => 200
    t.integer  "user_id",                                              :null => false
    t.integer  "user_short_code_id",                                   :null => false
    t.string   "content_type",       :limit => 10,                     :null => false
    t.boolean  "reply",                                                :null => false
    t.string   "reply_content",      :limit => 170
    t.integer  "web_service_id"
    t.boolean  "status",                            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "services", ["content_type"], :name => "idx_services_content_type"
  add_index "services", ["keyword"], :name => "idx_services_name"
  add_index "services", ["user_id"], :name => "idx_services_user_id"
  add_index "services", ["user_short_code_id"], :name => "fk_services_user_short_codes"
  add_index "services", ["web_service_id"], :name => "fk_services_web_services"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "short_codes", :force => true do |t|
    t.string   "code",       :limit => 20,                    :null => false
    t.string   "smsc",       :limit => 20,                    :null => false
    t.integer  "sms_cost"
    t.boolean  "status",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "short_codes", ["code"], :name => "idx_short_codes_code"
  add_index "short_codes", ["smsc"], :name => "idx_short_codes_smsc"

  create_table "user_details", :force => true do |t|
    t.integer  "user_id"
    t.string   "username",        :limit => 10,                    :null => false
    t.string   "hashed_password", :limit => 50,                    :null => false
    t.string   "salt",            :limit => 50,                    :null => false
    t.boolean  "parent",                        :default => false, :null => false
    t.boolean  "status",                        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_details", ["user_id"], :name => "fk_users_user_details"
  add_index "user_details", ["username"], :name => "idx_user_details_username"

  create_table "user_mod_services", :force => true do |t|
    t.integer  "user_mod_id"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_mod_services", ["service_id"], :name => "fk_user_mod_services_services"
  add_index "user_mod_services", ["user_mod_id"], :name => "fk_user_mod_services_user_details"

  create_table "user_short_codes", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "short_code_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_short_codes", ["short_code_id"], :name => "fk_user_short_codes_short_codes"
  add_index "user_short_codes", ["user_id"], :name => "fk_user_short_codes_users"

  create_table "users", :force => true do |t|
    t.string   "user_type",  :limit => 20,                    :null => false
    t.string   "name",       :limit => 30,                    :null => false
    t.string   "phone_no",   :limit => 15,                    :null => false
    t.string   "email",      :limit => 50,                    :null => false
    t.boolean  "sms_limit",                :default => false, :null => false
    t.integer  "sms_stock",                :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "idx_users_email"
  add_index "users", ["name"], :name => "idx_users_name"
  add_index "users", ["phone_no"], :name => "idx_users_phone_no"

  create_table "web_services", :force => true do |t|
    t.string   "name",             :limit => 20,                      :null => false
    t.string   "web_service_type", :limit => 20,                      :null => false
    t.string   "web_service_uri",  :limit => 500
    t.string   "post_xml_format",  :limit => 1000
    t.boolean  "default_param",                    :default => false, :null => false
    t.string   "param1",           :limit => 20
    t.string   "param2",           :limit => 20
    t.string   "param3",           :limit => 20
    t.string   "param4",           :limit => 20
    t.string   "param5",           :limit => 20
    t.string   "param6",           :limit => 20
    t.string   "param7",           :limit => 20
    t.string   "param8",           :limit => 20
    t.string   "param9",           :limit => 20
    t.string   "param10",          :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "web_services", ["name"], :name => "idx_web_services_name"
  add_index "web_services", ["web_service_type"], :name => "idx_web_services_web_service_type"

end
