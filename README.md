Tower Bridge
============

tower-bridge.rb is a bot that tweets the opening and closing of Tower Bridge. The code is presented for explanatory purposes; not so you can run your own bot, as it were.

Also: how to separate out OAuth configuration variables from a script that sends tweets - ie, so you can

Configuration
-------------

* Fill out your own creds.yml with the Twitter OAuth credentials you've acquired when you created an application on (developer.twitter.com)
* Put all these files on a server.
* Set up a cron task to download http://www.towerbridge.org.uk/TowerBridge/English/BridgeLifts/schedule.htm , once a day, to schedule.htm
* Run tower-bridge.rb (or whatever your file is called) once a minute. It will make tweets.
* That's it.
