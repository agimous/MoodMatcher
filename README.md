# README

MoodMatcher is an application to match a user's mood with his favourite music.
Users can browse and search music albums and add them to lists tagged by moods (happy, in love, pissed off, hateful, etc.)
Access to music data is accomplished by connecting to the MusicBrainz music metadata database (http://musicbrainz.org/).
Music data is fetched by HTTP requests. Users can create their own account and create lists of their favourite music albums.

MoodMatcher is an application developed for educational purpose.
It is being developed so that i learn Ruby on Rails while creating something that i consider useful.

* Version
	- ruby 2.2.5p319
	- Rails 5.0.0.1
	- SQLite3 3.14.2

* Services (job queues, cache servers, search engines, etc.)
	- MusicBrainz music metadata database (http://musicbrainz.org/)
	
* Deployment instructions

	To Deploy locally 
	- Create a new directory named 'MoodMatcher' and clone all the repository contents in it.
	- Open a command terminal and navigate to the newly created directory.
	- Get dependencies
		Run "bundle install". (Make sure you have bundler installed.)
	- Migrate DataBase
		bin/rails db:migrate
	- Start server
		bin/rails server
	- Open a browser and go to localhost:3000	


