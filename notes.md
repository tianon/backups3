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
	* IT coder
	* documenter
	* assistant manager
* Josh
	* primary coder
	* assistant tester
	* optimist
* Talon
	* sniper
	* coder
	* tester
	* not good looking enough to be a model/small weapon specialist

## Language

Perl for both the backup script, and the web interface.

It is definitely the best tool for the script job, and will make all our lives MUCH simpler if we use it for the web stuff, too.

## Source Control Software

Obviously, we're using Git.  I think that's enough said.

## Primary Features (must-haves)

* nightly cron job that performs the backups (asynchronously, preferably)
* Amazon S3 (easy, see <http://github.com/russross/s3fslite>)
* web interface for retrieving backups

	this merely needs to ask for the "bucket name", and the API keys, and then provide a nice interface for browsing their "backups"

## Bells and Whistles (to be implemented if time permits)

* (web) interface for configuration

	just manipulates the "scary plain-text" file in the user home directory

	this should be put way down low on the priority list, since it is not strictly necessary

## Remaining Tasks

* decide on configuration file format
* decide how configuration will work

	(default of include all files, or default of exclude all files?)
