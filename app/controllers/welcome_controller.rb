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
	
	logger.info "blah"
			
	@uri = URI(MUSICBRAINZ)

	@queryParams = createSearchQuery(@artist, @album)
	@params = { :query => @queryParams } 
	@uri.query = URI.encode_www_form(@params)
	
	@requestURI = @uri.request_uri
	@requestHost = @uri.host
	
	
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

	def createSearchQuery(artist, album)

		if @artist.nil?
			@artist = String.new("")
		end	
		if @album.nil?	
			@album = String.new("")
		end
		
		@params = ""
		
		
		
		if !@album.empty? then
			logger.info "Album field filled. Album : "+@album
			@params += '"' + @album + '"'
			if !@artist.empty? 
				logger.info "Artist field filled. Artist : "+@album
				@params += ' AND ' + 'artist:"' + @artist + '"'
			end
			@params += ' AND ' + 'type:"Album"'
		elsif !@artist.empty? then
			@params += 'artist:"' + @artist + '"'
			@params += ' AND ' + 'type:"Album"'
		else	
			# go back to search
			render 'index'
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
					logger.info "Artist array : "+release["artist_credit"]["name_credit"].to_s
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

