
<!-- <img src="inst/figures/stopmotion.png" width="120" align="right" /> -->

# APMD

<!-- badges: start -->

[![R-CMD-check](https://github.com/AlbanSagouis/APMD/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AlbanSagouis/APMD/actions/workflows/R-CMD-check.yaml)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![Code Coverage:
97%](https://img.shields.io/badge/code_coverage-97%25-brightgreen)
<!-- badges: end -->

## Analog Photography MetaData

The APMD package is the entry of the NOSSAFLEX file naming convention
into the R universe to help scientific, professional or amateur
photographers to name their picture files consistently and
informatively.

When taking a picture with an analog camera, data such as aperture,
shutter speed or focal length are not automatically saved the way they
are in a digital camera. Many photographers write down these precious
metadata in a notebook, we want to help them improve their workflow and
data quality.

## What is NOSSAFLEX?

Here is an explanation from the creators:

> It’s as easy as the name – NOSSAFLEX has all of the information in the
> title.
>
> NO = Number SS = Shutter Speed A = Aperture FL = Focal Length EX =
> Exposure

NOSSAFLEX file names looks like this: `NO03_SS250_A8_FL80_EX0.jpg` or
this: `NO34_SS30_A2.8_FL35_EX+1.tiff`!

Learn more on their [website](https://nossaflex.io/the-system) or on
their [Youtube channel](https://www.youtube.com/@NOSSAFLEX).

## The package

Here are the main functions in the package:

- `renaming_nossaflex` batch-renames picture files from uninformative
  `DSC_00345.jpg` to information-rich NOSSAFLEX name based on data
  provided by the user, see {analog} section:
  `NO03_SS250_A8_FL80_EX0.jpg`.
- `parsing_json` and `parsing_frames` parse data in JSON format as
  exported by the analog™ app and Frames™ app respectively.
- `editing_exif` batch-saves the metadata of the pictures into the exif
  slots of the scan files (jpg, tiff, etc).

## Analog™, Datafilm™, Frames™ or an other app

## The workflow

### Installation

You can install the released version of APMD from CRAN with:

``` r
install.packages("APMD")
```

Or the development version from GitHub with:

``` r
pak::pkg_install("AlbanSagouis/APMD@dev")
```

### Usage

#### Renaming files

This is a basic example which shows you how to solve a common problem:

``` r
library(APMD)
files <- c("Pictures/2024/01 02 Winter in Berlin/DSC_001034",
          "Pictures/2024/01 02 Winter in Berlin/DSC_001035",
          "Pictures/2024/01 02 Winter in Berlin/DSC_001036")
filenames <- reading_nossaflex(path = "path_to_the_filenames.txt") # provided by the `analog` app
renaming_nossaflex(filenames = filenames, files = files)
```

#### Saving exif data

Additionally you may want to safely save the shots metadata inside the
scan files:

``` r
metadata <- reading_nossaflex(path = "path_to_the_filenames.txt") |>  # provided by the `analog` app
     parsing_nossaflex()
editing_exif(files, metadata)
```

## Related work

The package relies heavily on the great `exiftoolr`
{<https://github.com/JoshOBrien/exiftoolr/>} package by @JoshOBrien
which itself depends on the great `exiftool` {<https://exiftool.org/>}
software by Phil Harvey. Finally, jExifToolGUI
{<https://github.com/hvdwolf/jExifToolGUI>} offers exif editing and with
a Graphical Interface, nice. And for Apple users, the Frames™ iPhone and
Mac apps allow integrated shot metadata recording and including the
metadata in the exif slots with a great GUI.
