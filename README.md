# Rails i18n Bundle #
by Ryan Stout
http://www.agileproductions.com/

extended by Isaac Sparling & Geoff Hichborn & Dariusz Gertych
## About ##

I did fine another Rails bundle that had i18n helpers, but none of them worked how I wanted them to, so I started over.

To make things easy, everything is based on using a default locale (english by default, which can be changed in Support/lib/config.rb)  It also assumes the location of the english file is config/locales/en.yml

Read more about rails i18n here: http://guides.rubyonrails.org/i18n.html

## Requirements ##

This bundle requires httparty, ruby-hmac, ya2yaml and google_translate to use.

	sudo gem install httparty ruby-hmac ya2yaml google_translate
	
It should work with ruby 1.8.7 or 1.9

## Install ##
To Install:

	mkdir -p ~/Library/Application\ Support/TextMate/Bundles
	cd ~/Library/Application\ Support/TextMate/Bundles
	git clone git://github.com/chytreg/rails_i18n.tmbundle.git "Rails i18n.tmbundle"
	osascript -e 'tell app "TextMate" to reload bundles'


### Add to locale ###

Select a section of text and hit CMD+SHIFT+I, this will then ask you for the token that identifies this string.  
By default the bundle will bulid create token according to the position of file. So inserted tokens will look like examples below:

	t('views.admin.users.new.your_token') or t('controllers.admin.users.new.your_token')

### Edit translation ###

Select a token key and hit CMD+SHIFT+E, this will try to find a text associated to the token. 
Will show a box with translated text, where you can easly edit translation. 

### Edit config ###
  
Select form bundle menu "Edit config" it will open config.yml where you can change defaults settings

### Calculate Cost ###

The bundle has support for mygengo.com translation api. Clicking on the calculate cost will give you a ESTIMATE of how much it will cost to translate your default locale into another language at the various qualities of mygengo.com

### Translate strings to language ###

Select form bundle menu "Translate strings to language" will ask you what locale you want to translate the default locale into.  You will then be asked how you want to translate the locale.  It will then loop through every string and translate the strings using the selected service.  Strings with existing translations will not be translated.

If you use google translate, translations will come back immediately.

The first time you choose to use MyGengo, you will be asked for your api_key and private_key

If you use *MyGengo.com*, you will be asked if you want translation jobs to be auto approved, if you choose no you will have to go onto mygengo.com and approve all strings.  When translating with mygengo.com, a placeholder will be inserted, then you can go to the bundle menu and select "Pull in MyGengo Translations" at a later point to pull in any finished translations.  You can do this as many times as is required.

## Issues ##

Please notice me if you find any :)
PS. I did a huge refactor. I didn't checked a MyGengo service because I'm not useing it.

### TODO ###

Any comments, suggestions, pull request are welcome!
 
