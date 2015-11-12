# Debian packaging quick guide

Simplified guide on how to build Debian packages

Can safely be used for tutorials.

## About

This is a working example of the process of creating a package for Debian-based systems.

You can just run the _build.sh_ script right away to create the package, though it won't be much of a package.

This was created as part of an in-house workshop on Debian packaging.
The targets were two:
- make packaging easier for beginners to understand
- create a packaging template that we can copy to a new project, modify and throw into a Jenkins server

Nothing more, nothing less.

The _build.sh_ script is supposed to be easy to read.

What does this script do? All the boring bits:
- checks for required files
- creates the directory structure
- copies the documentation, the metadata files and the content (ROOT) to the correct places in the structure
- gets the package name from the control file
- sets the version in the control file
- fixes permissions
- compresses files
- creates the actual package

Due to laziness, the changelog.Debian is populated by dumping the git log into it.

## Pre-requisite software

* Debian/Ubuntu system
* git
* lintian
* fakeroot
* tree (not mandatory, but very useful)
* text editor of your choice. That means vim.

## Usage

_ROOT_ is the base directory under which all dir structure and files for the package have to be placed.

There are two example files to show how the directory structure should look like
- ROOT/var/lib/package/package.txt
- ROOT/usr/lib/example-doc/placeholder.txt

Feel free to add stuff at random. It's your package after all.

For **every** file that you add/modify, it is advisable to go through the **Modification checklist**, so that you don't forget anything.

If you plan to use this for any remotely serious purpose, do the following **first**:

1. Remove the example files.
   `rm -r ROOT/var ROOT/usr`
2.Edit DEBIAN/control:
 * update at least the following fields:
  + Package: this is the name of the package. Small letters, numbers and dashes. No capitals
  + Provides: the name of the package or something generic (eg "java") that might be provided by other packages.
  + Description: short description.
 * The last line (indented by a space) is the extended description. Update it.

### Modification checklist

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
* lots of laziness in documentation and exception handling

