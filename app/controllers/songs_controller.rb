class SongsController < ApplicationController
  # GET /songs
  # GET /songs.json

  def reformat
    file = File.open('3.xml', 'r:UTF-8')

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
        print space + "<#{tag}>"  + value.to_s  + "</#{tag}>\n"
        #
        # Capturing two patterns here:
        #  <key>XXXX</key><true/>
        #  <key>XXXX</key><false/>
        #
      elsif line =~ /(\s+)<key>([a-zA-Z ]+)<\/key><(true|false)\/>/
        space = $1
        value = $3
        tag = $2.gsub(' ', '_')
        print space + "<#{tag}>"  + value.to_s  + "</#{tag}>\n"
        #
        # Everything else is not tranlsated
        #
      else
        print line
      end
    end
  end

  def reset
    @song = Song.find(params[:id])
    @song.update_attribute(:score, @song.score = 0)
    @song.save

    redirect_to :back
  end

  def vote_up
    @song  = Song.find(params[:id])

    if !session[:votes].include? @song.id
      session[:votes].push @song.id
      @song.score = @song.score + 1
      @song.save
    end

    redirect_to :back
  end

  def index
    @songs = Song.all
    @songs.sort!{|s1,s2|s2.score.to_i <=> s1.score.to_i}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @songs }
    end
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    @song = Song.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @song }
    end
  end

  # GET /songs/new
  # GET /songs/new.json
  def new
    @song = Song.new
    # @song.party_id = @party.find(params[:id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @song }
    end
  end

  # GET /songs/1/edit
  def edit
    @song = Song.find(params[:id])
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.new(params[:song])

    respond_to do |format|
      if @song.save
        format.html { redirect_to @song, notice: 'Song was successfully created.' }
        format.json { render json: @song, status: :created, location: @song }
      else
        format.html { render action: "new" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /songs/1
  # PUT /songs/1.json
  def update
    @song = Song.find(params[:id])

    respond_to do |format|
      if @song.update_attributes(params[:song])
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song = Song.find(params[:id])
    @song.destroy

    respond_to do |format|
      format.html { redirect_to songs_url }
      format.json { head :no_content }
    end
  end
end
