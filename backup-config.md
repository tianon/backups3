# Backup Configuration File

Here's an example:

	bucket
		i-has-a-bucket
	accessKeyId
		022QF06E7MXBSH9DHM02
	secretAccessKey
		kWcrlUX5JEDGM/LtmEENI/aVmYvHNif5zB+d9+ct
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
	exemption
		file
			something-important-bigger-than-a-gig.zip

## Clauses

* `bucket`
	* see [Amazon AWS "Security Credentials" page](http://aws.amazon.com/security-credentials)
		* is this really where we go to discover our current bucket names?
* `accessKeyId`
	* see [Amazon AWS "Security Credentials" page](http://aws.amazon.com/security-credentials)
* `secretAccessKey`
	* see [Amazon AWS "Security Credentials" page](http://aws.amazon.com/security-credentials)
* `include`
	* see Include/Exclude/Exemption section below
* `exclude`
	* see Include/Exclude/Exemption section below

## Include/Exclude/Exemption

To determine which files are included in the backup, the following steps are followed:

1. take all `include` rules, union them together
2. take all `exclude` rules, union them together
3. take all `exemption` rules, union them together
4. `include` - (`exclude` - `exemption`) = final list  
	(`exclude` rules are all applied to the final `include` list, but only after matching `exemption` files are removed from the `exclude` list)

### Rule Types

* `file`
	* one file/folder (`Desktop/`, `.bash_profile`)
* `glob`
	* shell-expansion (`*.h`, `help.?`, `test.{a,b,c}`)
	* specify specific folder for expanding within (`Desktop/`)
	* way to disable recursive expansion (`!`, as in `Desktop/!`)
* `size`
	* less than (`less than 20KB`)
	* greater than (`greater than 1MB`)
	* between (`between 2MB and 3MB`)
