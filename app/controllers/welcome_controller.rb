class WelcomeController < ApplicationController
  def index
  end
  
  def show
	 
	require 'net/http'
	require 'nokogiri'
	require 'json'
  
	@artist = params[:artist]
	@album = params[:album]
	
	logger.info "blah"
			
	@uri = URI('http://musicbrainz.org/ws/2/release-group/')
	#@uri = URI('https://api.discogs.com/database/search')
	@queryParams = createSearchQuery(@artist, @album)
	@params = { :query => @queryParams } 
	@uri.query = URI.encode_www_form(@params)
	
	
	
	@requestURI = @uri.request_uri
	@requestHost = @uri.host
	
	logger.info "Request to be done : " + @uri.to_s
	logger.info "Request to be done - request : " + @requestURI
	logger.info "Request to be done - host: " + @requestHost
	
	@req = Net::HTTP::Get.new(@uri.request_uri)
	@req.add_field("User-Agent","Mood Matcher/1.0 ( agism.job@gmail.com )")
	
	@http = Net::HTTP.new(@uri.host)
	@res = @http.request(@req)
	@body =  Hash.from_xml(@res.body).to_json # convert xml to json
	
	@albumsList = parseJSONAlbums(@body)
	logger.info "Album List : "+@albumsList.to_s
	
	#@xml.xpath("//title")

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
				@uri = URI("http://coverartarchive.org/release-group/"+@albumID+"/front")
				@req = Net::HTTP::Get.new(@uri.request_uri)
				@req.add_field("User-Agent","Mood Matcher/1.0 ( agism.job@gmail.com )")
	
				@http = Net::HTTP.new(@uri.host)
				@res = @http.request(@req)
				#needs check for request failure or success
				@albumCover = @res.body[/http:.+\.jpg/]
				#logger.info "Album Cover response: "+@albumCover
				
				#year
				#http://musicbrainz.org/ws/2/freedb/?query=discid:6e108c07
				#@uri = URI("http://musicbrainz.org/ws/2/freedb/?query=artist:"+@artistName+" AND "+"title:"+@albumTitle)
				#@req = Net::HTTP::Get.new(@uri.request_uri)
				#@req.add_field("User-Agent","Mood Matcher/1.0 ( agism.job@gmail.com )")
	
				#@http = Net::HTTP.new(@uri.host)
				#@res = @http.request(@req)
				#@body =  Hash.from_xml(@res.body).to_json 
				#needs check for request failure or success
				#@albumYear = body["freedb_disc_list"]["freedb_disc"]["year"]
				#logger.info "Album year response: "+@albumYear
				
				
				@albumEntry = { "albumID" => @albumID, "albumTitle" => @albumTitle, "artist" => @artistName, "albumCover" => @albumCover, "genre" => @genre }
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

