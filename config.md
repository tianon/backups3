# Configuration File Syntax

Here's an example:

	include
		glob
			./|*.{h,c,cpp}
			Desktop/!|*.txt
		file
			Desktop/
			.bash_profile
		size
			less than 20KB
			between 2MB and 3MB
	exclude
		size
			greater than 1GB

## Include/Exclude Types

* file
	* one file/folder (`Desktop/`, `.bash_profile`)
* glob
	* shell-expansion (`*.h`, `help.?`, `test.{a,b,c}`)
	* specify specific folder for expanding within
	* way to disable recursive expansion
* size
	* less than (`less than 20KB`)
	* greater than (`greater than 1MB`)
	* between (`between 2MB and 3MB`)
