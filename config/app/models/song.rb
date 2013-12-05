class Song < ActiveRecord::Base
  attr_accessible :song_album, :song_artist, :song_duration, :song_location, :song_name, :party_id, :score
  belongs_to :party, :dependent => :destroy
end

