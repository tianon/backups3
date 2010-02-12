# Project Plan

## Responsibilities

* Andrew
	* primary coder
	* tester
* Ben
	* coder
	* manager
* Jonathan
	* IT/VT (web based) coder
	* documenter
	* assistant manager
* Josh
	* primary config coder
	* assistant tester
* Talon
	* secondary config coder
	* tester

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

Waterfall

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

## Software Requirements

### Server

* Ubuntu 8.04+ / Debian 4+ (or other Linux distribution)
* PHP 5.1+
* Perl 5.8+
* Apache 2
* Git

### Client

* any web browser

## Hardware Requirements

### Server

* 700 MHz x86 processor
* 384 MB of system memory (RAM)
* 4 GB of disk space
* network or Internet connection

### Client

* connection to the Internet

## Other Requirements

* Internet access (WiFi or Ethernet)
* individual computers
* comfortable work area (AC, bathroom, etc.)
* recreational facilities for health and happiness
