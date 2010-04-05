# Global Configuration File

Here's an example:

	backupConfigFilename
		.backups3
	backupConfigEnforcedMode
		0600
	include
		/home|3
		/var/www|*

## Clauses

* `backupConfigFilename`
	* `filename` (defaults to `.backups3`)
* `backupConfigEnforcedMode`
	* the three-digit file permissions to be required on _all_ backup configuration files (defaults to `0600`)
* `include`
	* `absolute_path|depth`
		* `absolute_path`: `/home`, `/var/www`, etc.
		* `depth`: `3`, `*` (meaning infinite depth; doesn't follow symlinks unless they are explicitly listed as `include` lines), etc.

### Detailed Example

Assumed Directory Structure:

	/home:
		a/
		b/
		j/
		t/
		
	/home/a:
		andrew/
		
	/home/a/andrew:
		.backups3
		
	/home/b:
		ben/
		
	/home/j:
		jon/
		josh/
		
	/home/t:
		talon/
		
	/home/t/talon:
		temp/
		
	/home/t/talon/temp:
		.backups3

If `include` in the global configuration specifies `/home|3`, with a `backupConfigFilename` of `.backups3`, we would include the following files in our search:

	/home/.backups3
	/home/a/.backups3
	/home/a/andrew/.backups3
	/home/b/.backups3
	/home/b/ben/.backups3
	/home/j/.backups3
	/home/j/jon/.backups3
	/home/j/josh/.backups3
	/home/t/.backups3
	/home/t/talon/.backups3

As you can see, `/home/t/talon/temp/.backups3` would be ignored, but any of the above files, assuming they exist and have proper permissions as per `backupConfigEnforcedMode`, would be fair game for processing, so `/home/a/andrew/.backups3` would be processed.
