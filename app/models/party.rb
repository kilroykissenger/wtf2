class Party < ActiveRecord::Base
  attr_accessible :id, :start_date, :end_date, :url, :party_name, :party_location, :party_type, :party_details
  attr_accessible :playlist

  has_many :songs, :dependent => :destroy
  has_many :users

  def playlist=(uploaded_io)
    file = File.open(Rails.root.join(uploaded_io.original_filename), 'w')
    file.write(uploaded_io.read)
    raw = uploaded_io.original_filename
    file.close
    reformat raw
  end

  def reformat(raw)
  file = File.open(raw, 'r:UTF-8')
  newFile = File.open(Rails.root.join(raw + ".new"), 'w')


  file.each do |line|

#
#  Just for debugging.
#  print "Reading " + line
#

# Capturing two patterns here:
#  <key>XXXX</key><string>YYYY</string>
#  <key>XXXX</key><integer>ZZZZ</integer>
#
      if line =~ /(\s+)<key>([a-zA-Z ]+)<\/key><(string|integer)>([^<]+)<\/(string|integer)>/
        space = $1
        value = $4
        tag = $2.gsub(' ', '_')
        newFile.write space + "<#{tag}>"  + value.to_s  + "</#{tag}>\n"
        #
        # Capturing two patterns here:
        #  <key>XXXX</key><true/>
        #  <key>XXXX</key><false/>
        #
      elsif line =~ /(\s+)<key>([a-zA-Z ]+)<\/key><(true|false)\/>/
        space = $1
        value = $3
        tag = $2.gsub(' ', '_')
        newFile.write space + "<#{tag}>"  + value.to_s  + "</#{tag}>\n"
        #
        # Everything else is not tranlsated
        #
      else
        newFile.write line
      end

  end
  newFile.close
  import newFile
  end

  def import (newFile)
    require 'rexml/document'
    file = File.open(newFile, 'r:UTF-8')
    xml = file.read

    doc = REXML::Document.new(xml)

    count = 0
    doc.elements.each("plist/dict/dict/dict") do |dict|

      #
      # create a Track object for each "dict"
      #
      song = Song.new

      if dict.elements['Name']
        song.song_name= dict.elements['Name'].text
      end

      if dict.elements['Artist']
        song.song_artist = dict.elements['Artist'].text
      end

      if dict.elements['Album']
        song.song_album = dict.elements['Album'].text
      end

      if dict.elements['Total_Time']
        song.song_duration = dict.elements['Total_Time'].text
      end

      if dict.elements['Location']
        song.song_location = dict.elements['Location'].text
      end

      count += 1
      song.party_id = id
      song.save
    end

  end

end