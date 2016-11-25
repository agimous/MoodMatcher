class WelcomeController < ApplicationController
  def index
  end
  
  def show
	
	require 'net/http'
	require 'nokogiri'
	require 'json'
  
	@artist = params[:artist]
	@album = params[:album]
	@uri = URI('http://musicbrainz.org/ws/2/release-group/')
	#@uri = URI('https://api.discogs.com/database/search')
	@queryParams = "artist:"+@artist+" AND "+"release:"+@album
	#@queryParams = "artist="+@artist+"&"+"release_title="+@album
	@params = { :query => @queryParams } 
	@uri.query = URI.encode_www_form(@params)
	
	
	@requestURI = @uri.request_uri
	@requestHost = @uri.host
	
	@req = Net::HTTP::Get.new(@uri.request_uri)
	@req.add_field("User-Agent","Mood Matcher/1.0 ( agism.job@gmail.com )")
	
	@http = Net::HTTP.new(@uri.host)
	@res = @http.request(@req)
	@body =  Hash.from_xml(@res.body).to_json # convert xml to json
	@parsed = JSON.parse(@body)
	
	
	@releases = @parsed["metadata"]["release_group_list"]["release_group"]


	#@xml.xpath("//title")

  end
  
  
end
