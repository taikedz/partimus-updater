# partimus-updater

Update scripts for partimus project

by Tai Kedzierski independently, for Partimus.org

Licensed under LGPLv3

**These scripts are still in testing stage and not yet suitable for production**

## How to use this repo

1. Install
	* If you are non technical
		* open a command line
		* Copy and paste the following:
		* `curl https://raw.githubusercontent.com/taikedz/partimus-updater/master/bin/install.sh | sudo bash`
		* Do this on each client machine that needs to benefit from the partimus updates
	* If you are technical
		* install `git`
		* clone this repository `git clone https://github.com/taikedz/partimus-updater/`
		* `cd partimus-updater`
		* run `sudo bin/install.sh`
2. Maintain
	* If you want to push changes to this repo on github:
		* fork the repo
		* create a new branch
		* make your changes (see scripts section)
		* make a pull request to the development branch
	* If you want to specify a different repository
		* before running the install script, edit the `giturl` variable
		* simply pull from a different repository

## Scripts

The `scripts/` directory is a collection of scripts that will be run, in alphabetical order. Any executable file will be run.

The scripts are run without arguments.

Add new scripts with a numerical prefix (to ensure execution order) and make them executable. Push your new scripts to development branch.

When the scripts reach the master branch, they will be pulled and run on the client machines.

## Building the main scripts in `src`

You should not need to edit the main scripts often, but if you do:

The scripts in `src` are built using the `bash-builder` tool: https://github.com/taikedz/bash-builder (latest build with version 1.1.6 of the bash-libs)

They are then copied to `bin/`
