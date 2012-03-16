class Ringtone < ActiveRecord::Base
  has_many :ringtone_access_key
  validates :keyword, :presence =>{:message => "Keyword can't be blank"},
    :uniqueness => {:message => "Keyword has been taken"}
  validates :song_title, :presence =>{:message => "Song title can't be blank"}
  validates :artist_name, :presence =>{:message => "Artist name can't be blank"}

end
