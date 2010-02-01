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

## Include/Exclude

To determine which files are included in the backup, the following steps are followed:

1. take all `include` rules, union them together
2. take all `exclude` rules, union them together
3. `include` - `exclude` = final list (`exclude` rules are all applied to the final `include` list)

### Types

* `file`
	* one file/folder (`Desktop/`, `.bash_profile`)
* `glob`
	* shell-expansion (`*.h`, `help.?`, `test.{a,b,c}`)
	* specify specific folder for expanding within
	* way to disable recursive expansion
* `size`
	* less than (`less than 20KB`)
	* greater than (`greater than 1MB`)
	* between (`between 2MB and 3MB`)
