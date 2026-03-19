# insert_missing_records works as expected with NOSSAFLEX

    Code
      insert_missing_records(metadata = metadata, row_indices = 2L, new_rows = new_rows)
    Output
                T     NO     SS      A     FL     EX
           <char> <char> <char> <char> <char> <char>
      1: est roll     01    250    2.8     50     +2
      2: est roll     02    125    1.4     50      0
      3: est roll     03    250    2.8     50     -1

# insert_missing_records works as expected with JSON

    Code
      insert_missing_records(metadata = metadata, row_indices = 5:7, new_rows = new_rows,
      extrapolate_data = TRUE)
    Output
          Roll_Name Roll_Number Camera_Brand Camera_Model     NO     SS      A     FL
             <char>      <char>       <char>       <char> <char> <char> <char> <char>
       1: Test-week         005 Voigtlaender      Vito 70     01   auto   auto       
       2: Test-week         005 Voigtlaender      Vito 70     02   auto   auto       
       3: Test-week         005 Voigtlaender      Vito 70     03   auto   auto       
       4: Test-week         005 Voigtlaender      Vito 70     04   auto   auto       
       5: Test-week         005 Voigtlaender      Vito 70     05   auto   auto   <NA>
       6: Test-week         005 Voigtlaender      Vito 70     06   auto   auto       
       7: Test-week         005 Voigtlaender      Vito 70     07   auto   auto   <NA>
       8: Test-week         005 Voigtlaender      Vito 70     08   auto   auto       
       9: Test-week         005 Voigtlaender      Vito 70     09   auto   auto   <NA>
      10:      <NA>        <NA>         <NA>         <NA>     10   <NA>   <NA>   <NA>
      11: Test-week         005 Voigtlaender      Vito 70     11   auto   auto       
          Lens_Brand Lens_Maximum_Aperture Lens_Focal_Length     EX
              <list>                <list>            <char> <char>
       1:     [NULL]                [NULL]                70      0
       2:     [NULL]                [NULL]                70      0
       3:     [NULL]                [NULL]                70      0
       4:     [NULL]                [NULL]                70      0
       5:     [NULL]                [NULL]              <NA>   <NA>
       6:     [NULL]                [NULL]                70      0
       7:     [NULL]                [NULL]              <NA>   <NA>
       8:     [NULL]                [NULL]                70      0
       9:     [NULL]                [NULL]              <NA>   <NA>
      10:     [NULL]                [NULL]              <NA>   <NA>
      11:     [NULL]                [NULL]                70      0
                 Date_Time_Original  Latitude   Longitude Northing Easting
                             <char>    <char>      <char>   <char>  <char>
       1: 2024-02-29 16:41:27 +0000   52.4356 13.79876534        N       E
       2: 2024-03-03 15:22:00 +0000 52.465743     12.3456        N       E
       3: 2024-03-03 15:27:12 +0000   52.3456    13.65789        N       E
       4: 2024-03-03 15:30:57 +0000   52.1234     13.6789        N       E
       5:                     NA NA      <NA>        <NA>     <NA>    <NA>
       6: 2024-03-10 13:37:39 +0000    51.234     12.2345        N       E
       7:                     NA NA      <NA>        <NA>     <NA>    <NA>
       8: 2024-03-13 15:23:13 +0000   52.4567     13.6789        N       E
       9:                     NA NA      <NA>        <NA>     <NA>    <NA>
      10:                      <NA>      <NA>        <NA>     <NA>    <NA>
      11: 2024-03-13 15:23:13 +0000   52.4567     13.6789        N       E

# insert_missing_records works as expected with JSON and extrapolation

    Code
      insert_missing_records(metadata = metadata, row_indices = 5:7, new_rows = new_rows,
      extrapolate_data = FALSE)
    Output
          Roll_Name Roll_Number Camera_Brand Camera_Model     NO     SS      A     FL
             <char>      <char>       <char>       <char> <char> <char> <char> <char>
       1: Test-week         005 Voigtlaender      Vito 70     01   auto   auto       
       2: Test-week         005 Voigtlaender      Vito 70     02   auto   auto       
       3: Test-week         005 Voigtlaender      Vito 70     03   auto   auto       
       4: Test-week         005 Voigtlaender      Vito 70     04   auto   auto       
       5: Test-week         005 Voigtlaender      Vito 70     05   auto   auto   <NA>
       6: Test-week         005 Voigtlaender      Vito 70     06   auto   auto       
       7: Test-week         005 Voigtlaender      Vito 70     07   auto   auto   <NA>
       8: Test-week         005 Voigtlaender      Vito 70     08   auto   auto       
       9: Test-week         005 Voigtlaender      Vito 70     09   auto   auto   <NA>
      10:      <NA>        <NA>         <NA>         <NA>     10   <NA>   <NA>   <NA>
      11: Test-week         005 Voigtlaender      Vito 70     11   auto   auto       
          Lens_Brand Lens_Maximum_Aperture Lens_Focal_Length     EX
              <list>                <list>            <char> <char>
       1:     [NULL]                [NULL]                70      0
       2:     [NULL]                [NULL]                70      0
       3:     [NULL]                [NULL]                70      0
       4:     [NULL]                [NULL]                70      0
       5:     [NULL]                [NULL]              <NA>   <NA>
       6:     [NULL]                [NULL]                70      0
       7:     [NULL]                [NULL]              <NA>   <NA>
       8:     [NULL]                [NULL]                70      0
       9:     [NULL]                [NULL]              <NA>   <NA>
      10:     [NULL]                [NULL]              <NA>   <NA>
      11:     [NULL]                [NULL]                70      0
                 Date_Time_Original  Latitude   Longitude Northing Easting
                             <char>    <char>      <char>   <char>  <char>
       1: 2024-02-29 16:41:27 +0000   52.4356 13.79876534        N       E
       2: 2024-03-03 15:22:00 +0000 52.465743     12.3456        N       E
       3: 2024-03-03 15:27:12 +0000   52.3456    13.65789        N       E
       4: 2024-03-03 15:30:57 +0000   52.1234     13.6789        N       E
       5:                      <NA>      <NA>        <NA>     <NA>    <NA>
       6: 2024-03-10 13:37:39 +0000    51.234     12.2345        N       E
       7:                      <NA>      <NA>        <NA>     <NA>    <NA>
       8: 2024-03-13 15:23:13 +0000   52.4567     13.6789        N       E
       9:                      <NA>      <NA>        <NA>     <NA>    <NA>
      10:                      <NA>      <NA>        <NA>     <NA>    <NA>
      11: 2024-03-13 15:23:13 +0000   52.4567     13.6789        N       E

