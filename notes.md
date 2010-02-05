# Project Notes and Planning

## Responsibilities

* Andrew
	* sniper
	* primary coder
	* tester
	* just about everything/ultimate killer of all
* Ben
	* coder
	* manager
	* whatever is left
* Jonathan
	* IT/VT (web based) coder
	* documenter
	* assistant manager
	* with his IT background, Jon is now primary over all VT, ie. Web UI
* Josh
	* primary config coder
	* assistant tester
	* optimist
* Talon
	* sniper
	* secondary config coder
	* tester
	* not good looking enough to be a model/small weapon specialist

## Language

Perl for both the backup script, and the web interface.

It is definitely the best tool for the script job, and will make all our lives MUCH simpler if we use it for the web stuff, too.

## Source Control Software

Obviously, we're using Git.  I think that's enough said.

## Primary Features

* nightly cron job that performs the backups (asynchronously, preferably)
* Amazon S3 (see <http://github.com/russross/s3fslite>, or s3fslite submodule in this repository)
* web interface for retrieving backups
	* this merely needs to ask for the "bucket name" and the API keys, and then provide a nice interface for browsing their "backups"
* web interface for configuration
	* just manipulates the "scary plain-text" file in the user home directory
	* this is our one and only "Dixie State College CIT Network" specific part, and if we do it right, even this can be generalized so that it is usable to others

## Remaining Tasks

* implement cron job
	* Andrew, Ben
* implement web interface (browsing backups)
	* Andrew, Ben, Jon
* implement web interface (configuration)
	* Jon, Josh, Talon

## More Information

### Style

Waterfall.

### Stakeholders

* Faculty
	* Russ Ross
* Students

### Schedule

* Feb 28th - Design and Planning finished  
	Feb 5th - Planning Complete  
	Feb 28th - Design Complete
* Apr 1th - Coding Complete  
	(both web interfaces and perl back-end done)
* Apr 28th - Testing &amp; Documentation  
	Apr 14th - Testing Complete
