# rdrprep tool

Version 00.02
December 2, 2002


## Overview

This program prepares an ASCII file for submission to a Hercules virtual card reader.  It reads the input file, and provides a mechanism to include either ASCII or EBCDIC files within.  Files are included by specifying an 'include'
statement (beginning in column 1) whose format is: `::C filename` where:

* `::` include escape characters
* `C` is one of `E` for raw **EBCDIC** or `A` for **ASCII**
* `filename` file you wish to include

For example:

```
Hello this is an ASCII file
::a /home/text.txt

Hello this is an EBCDIC file
::e /home/ebcdic.file
```

Would include both `test.txt` and `ebcdic.file`, translating all ASCII to EBCDIC.

Typically you would use this to submit jobs to a hercules reader for something like **tk4-** assuming the reader was in EBCDIC mode by specifying `ebcdic` instead of `ascii` on the reader line.

Here's an example from **tk4-**

* Original: `000C 3505 ${RDRPORT:=3505} sockdev ascii trunc eof`
* Updated: `000C 3505 3505 sockdev ebcdic trunc eof`


Some things to concider:
* The main input deck (i.e. the file you wish to convert) is assumed to be encoded in **ASCII**.
* The output deck will be in **EBCDIC**, fixed length (lrecl) records. Currently, the only supported lrecl is 80.
* Input lines longer than lrecl will be truncated, shorter lines padded out to lrecl length.
* **ASCII** input files are assumed to be of variable line length,
* **EBCDIC** input files are assumed to be of fixed (lrecl) length.

## Install

Type `make` to build, then `sudo make install` to install to `/usr/local/bin/rdrprep`

To remove files, use `sudo make clean`

## Sample Help from "rdrprep +help" execution
 
```
This program prepares an ASCII file for submission to a Hercules virtual
card reader.  It reads the input file, and provides a mechanism to include
other (ASCII or EBCDIC) files.  Files are included by specifying an 'include'
statement (beginning in column 1) whose format is:
        ::C [path]filename
where:
        ::              are the include escape characters
        C               either E (EBCDIC) or A (ASCII) for the included file's
                        character set.  The case of E or A is not significant.
        [path]filename  specifies the filename and optional path of the file
                        to be included.
 
The main input file (specified on the command line) is assumed to be in
ASCII.  ASCII files are assumed to be of variable line lengths, EBCDIC
files are assumed to be of fixed length.  All input lines are translated
to EBCDIC (if necessary), and blank padded or truncated to 80 characters.
Include statements are only recognized in ASCII input files.
 
 
Syntax: rdrprep [options...] input [output]
 
 input     input filename
 output    output filename (default reader.jcl)
 
Default options    on/yes(+)   off/no(-)    HELP (default: not displayed)
------------------------------------------- ------------------------------
-list    echo output (translated to ASCII)  -about    copyright & version
+trunc   truncate long ASCII lines (80)     -help     general help
                                            -syntax   syntax help
                                                                    
```

## Sample execution



```jcl
bash-2.04# cat test.jcl
//TEST JOB CLASS=A,MSGLEVEL=(1,1)
//UPDTE    EXEC PGM=IEBUPDTE
//SYSPRINT  DD  SYSOUT=A
//SYSUT1    DD  DISP=OLD,DSN=SYS2.LOCAL.ASM
//SYSUT2    DD  DISP=OLD,DSN=SYS2.LOCAL.ASM
//SYSIN     DD  *
./ ADD NAME=JUNK
::a first.include.txt
./ ADD NAME=IEFBR14
::a iefbr14.asm
//LINK     EXEC PGM=IEWL,PARM='MAP'
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DISP=SHR,DSN=SYS2.LOCAL.LINKLIB(IEFBR14)
//SYSUT1    DD UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSLIN    DD *
::e iefbr14.obj
//IEFBR14  EXEC PGM=IEFBR14
//STEPLIB   DD DSN=SYS2.LOCAL.LINKLIB,DISP=SHR
//         
```

```
bash-2.04# rdrprep +list test.jcl
//TEST JOB CLASS=A,MSGLEVEL=(1,1)
//UPDTE    EXEC PGM=IEBUPDTE
//SYSPRINT  DD  SYSOUT=A
//SYSUT1    DD  DISP=OLD,DSN=SYS2.LOCAL.ASM
//SYSUT2    DD  DISP=OLD,DSN=SYS2.LOCAL.ASM
//SYSIN     DD  *
./ ADD NAME=JUNK
First Include Text Line 1
First Include Text Line 2
Second Include Text Line 1
Second Include Text Line 2
Second Include Text Final Line
First Include Text Final Line
./ ADD NAME=IEFBR14
IEFBR14  CSECT ,
         SLR   15,15
         BR    14
         END   IEFBR14
//LINK     EXEC PGM=IEWL,PARM='MAP'
//SYSPRINT  DD SYSOUT=*
//SYSLMOD   DD DISP=SHR,DSN=SYS2.LOCAL.LINKLIB(IEFBR14)
//SYSUT1    DD UNIT=SYSDA,SPACE=(TRK,(5,5))
//SYSLIN    DD *
 ESD            IEFBR14                                                 00000001
 TXT                                                                    00000002
 END                            1X390ASM   210001038                    00000003
//IEFBR14  EXEC PGM=IEFBR14
//STEPLIB   DD DSN=SYS2.LOCAL.LINKLIB,DISP=SHR
//    
```

## Version history


| Version | Date Released | Comments      |
|  :---:  |     :---:     | ------------- |
| 00.00   | 02/07/2001    | Base release  |
| 00.01   | 04/07/2001    | Ignores zero length ASCII input records |
| 00.02   | 12/02/2002    | Incorporate Mike Rayborn's fix for long ASCII lines, as reported in the Yahoo turnkey-mvs group. <br>  Added trunc option; -trunc will wrap long ASCII lines (for example HTML files); similar to old behavior. Default is +trunc (truncate ASCII input at 80 bytes). |
