# CRAN submission — APMD 0.1.0

## Test environments

* macOS (local), R 4.x
* GitHub Actions: ubuntu-latest, windows-latest, macOS-latest (R-release, R-devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Method references

There are no published references describing the methods in this package.
The package implements a workflow around the NOSSAFLEX file-naming convention
for analog photography metadata, using 'exiftoolr' as the EXIF writing backend.

## URL check notes

`urlchecker::url_check()` reports 403 errors for several `https://www.loc.gov/item/`
URLs in the vignette. These are valid Library of Congress item pages that block
automated HTTP requests; they resolve correctly in a browser.

## Notes for reviewers

* The package depends on 'exiftoolr', which itself wraps the external command-line
  tool ExifTool (by Phil Harvey). ExifTool must be installed on the user's system;
  'exiftoolr' handles detection and installation prompts at runtime.
* Examples that write to or rename files are wrapped in `\dontrun{}` to avoid
  modifying files on the reviewer's system.
