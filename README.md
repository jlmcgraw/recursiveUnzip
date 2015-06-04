# recursiveUnzip
For Linux: Recursively unzip a .zip archive and any .zip files inside it

Modified from code at at http://www.dbforums.com/showthread.php?1619154-how-to-unzip-files-recursively<br>

Other bits from http://tuxtweaks.com/2014/05/bash-getopts/<br>

  Recursively unzip files and any archives inside them

  Basic usage:
   ./recursiveUnzip.sh <switches> file1.zip file2.zip ... fileN.zip

  Command line switches are optional. The following switches are recognized:

  -d  --Delete the input file(s) after processing<br>
  -h  --Displays this help message. No further functions are performed"

  Example: ./recursiveUnzip.sh -d test.zip
