# Skeleton directory for creating Debian packages 

Simplified guide on how to build Debian packages

Can safely be used for tutorials.

## About

TODO: Add a description about the package here

## Init

There are two example files to show how the directory structure should look like
- ROOT/var/lib/package/package.txt
- ROOT/usr/lib/example-doc/placeholder.txt

Before doing anything serious, do the following:

1. Remove the example files.
`rm -r ROOT/var ROOT/usr`

2.Edit DEBIAN/control:
 * update at least the following fields:
  + Package: this is the name of the package. Small letters, numbers and dashes. No capitals
  + Provides: the name of the package or something generic (eg "java") that might be provided by other packages.
  + Description: short description.
 * The last line (indented by a space) is the extended description. Update it.

## Modification checklist

For each one of your added/modified files, you need to run through the checklist below.

Obviously, the mandatory part is 100% mandatory. Skip it and you'll get packaging problems.

The optional part will not cause functional problems, but will cause less warnings when doing a syntax check.

#### mandatory

* Add file in their correct place under the ROOT directory. Create dirs as needed.
* Enforce permissions for the file:
 + Edit build.sh
 + Go to "TODO: fix extra permissions here"
 + 0755 for executables, 0644 for others
* Do the following files need to be updated?
 + DEBIAN/control
 + DEBIAN/postinst
 + DEBIAN/prerm
* Is the file a configuration file?
 + Add its final path in DEBIAN/conffiles

#### optional

* Update ./DOC/copyright
* Update the manpage (./DOC/man)
* Update the changelog. This is not needed, so it's skipped by default.  
 + update ./DOC/changelog
 + Include the file in the package:
  - edit build.sh
  - go to `# changelog` section
  - uncomment as needed
* Update the Debian changelog. By default this is the git log.
 + update ./DOC/changelog.Debian
 + edit build.sh
  - go to `# changelog.Debian` section
  - comment-uncomment as needed


## Pre-requisites for building the package

* Debian/Ubuntu system.
* git
* lintian
* fakeroot

## Building the package

#### Build 

`./build.sh -v VERSIONNUMBER`

Creates `target/PACKAGENAME-VERSIONNUMBER.deb`.

#### Test

`lintian target/PACKAGENAME-VERSIONNUMBER.deb`

## Known problems

* changelog is not properly formatted (created by output of `git log`).
* man page is not properly formatted.
* man page is (1) by default.
* package is not signed.


