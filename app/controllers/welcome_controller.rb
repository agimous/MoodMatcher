class WelcomeController < ApplicationController

MUSICBRAINZ = 'http://musicbrainz.org/ws/2/release-group/'
MUSICBRAINZCOVERS = 'http://coverartarchive.org/release-group/'
APPSIGNATURE = 'Mood Matcher/1.0 ( agism.job@gmail.com )'

  def index
  end
  
  def show
	 
	require 'net/http'
	require 'json'
  
	@artist = params[:artist]
	@album = params[:album]
			
	@uri = URI(MUSICBRAINZ)

	@queryParams = createSearchQuery(@artist, @album)
	redirect_to action: "index" and return if @queryParams.empty?
	
	@params = { :query => @queryParams } 
	@uri.query = URI.encode_www_form(@params)
	
	@req = Net::HTTP::Get.new(@uri.request_uri)
	@req.add_field("User-Agent",APPSIGNATURE)
	
	@http = Net::HTTP.new(@uri.host)
	
	@connection = true
	begin  
		@res = @http.request(@req)
	rescue  
		@connection = false
	end 
	
	
	if @connection then
		@body =  Hash.from_xml(@res.body).to_json # convert xml to json
		@albumsList = parseJSONAlbums(@body)
	end	
	

  end
  



private

	# Construct the search query that will be 
	# attached to the http request to MusicBrainz DB.
	def createSearchQuery(artist, album)

		@artist = String.new("") if @artist.nil?
		@album = String.new("") if @album.nil?	
			
		@params = ""
		
		if !@album.empty? then
			@params += '"' + @album + '"'
			if !@artist.empty? 
				@params += ' AND ' + 'artist:"' + @artist + '"'
			end
			@params += ' AND ' + 'type:"Album"'
		elsif !@artist.empty? then
			@params += 'artist:"' + @artist + '"'
			@params += ' AND ' + 'type:"Album"'
		end
		
		return @params
	end

	#Store the data that was fetched
	def parseJSONAlbums(body)
		
		@parsed = JSON.parse(@body)
		@releases = @parsed["metadata"]["release_group_list"]["release_group"]
		
		@albums = Array.new() 
		
		#force into array 
		if !@releases.kind_of?(Array) then
			 @releases = [@releases] 
		end 
		
		@releases.each do |release| 
		
			unless release.nil? then 
			
				#release-id
				@albumID = release["id"]
				
				#album title
				unless release["title"].nil? then 
					@albumTitle = release["title"]
				end	
				
				#artist name
				if release["artist_credit"]["name_credit"].kind_of?(Array) then 
					@artistName = ""
					release["artist_credit"]["name_credit"].each do |oneArtist|
						@artistName += oneArtist["artist"]["name"] + ", "
					end
				else
					unless release["artist_credit"]["name_credit"]["artist"]["name"].nil? then	
						@artistName = release["artist_credit"]["name_credit"]["artist"]["name"] 
					end
				end
				
				#genre
				@genre = ""	
				unless release["tag_list"].nil? then 
					@releaseTags = release["tag_list"]["tag"]
					if @releaseTags.kind_of?(Array) then 
						@releaseTags.each do |releaseTag|
							unless releaseTag.nil?  then 
								@genre += releaseTag["name"] + " , "	
							end	
						end
					else
						@genre += @releaseTags["name"]
					end 
					 
				end 
			
				
				
				#album cover
				@uri = URI(MUSICBRAINZCOVERS+@albumID+"/front")
				@req = Net::HTTP::Get.new(@uri.request_uri)
				@req.add_field("User-Agent","Mood Matcher/1.0 ( agism.job@gmail.com )")
	
				@http = Net::HTTP.new(@uri.host)
				@res = @http.request(@req)
				@albumCover = @res.body[/http:.+\.jpg/]
				
				
				
				@albumEntry = { "albumID" => @albumID, "name" => @albumTitle, "artist" => @artistName, "cover" => @albumCover, "genre" => @genre }
				logger.info "Album Entry : "+@albumEntry.to_s
				
				unless @albumTitle.nil? then
					@albums.push(@albumEntry)
				end
				
			end	
			
		end 
		#logger.info "Albums : "+@albums.to_s
		return @albums

	end
end

