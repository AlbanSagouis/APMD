# APMD 0.1.0

* First release on CRAN.
* `parsing_nossaflex()`: parse NOSSAFLEX-structured file names into a data.frame.
* `parsing_json()`: parse shot metadata exported by the 'analog' app (JSON format).
* `parsing_frames()`: parse shot metadata exported by the 'Frames' app (.frames format).
* `reading_nossaflex()`: read NOSSAFLEX file names from a text file.
* `renaming_nossaflex()`: batch-rename scan files using NOSSAFLEX names.
* `editing_exif()`: batch-write shot metadata into EXIF slots of scan files.
* `insert_missing_records()`: insert rows for missing shots into a metadata data.table.
* `add_lens_data_*()`: helper data.frames for common Nikon and Sigma lens configurations.
