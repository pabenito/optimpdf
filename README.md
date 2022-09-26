# optimpdf (optimize-pdf) 

Command line tool to optimize PDF, individually, searching by pattern or an entire folder.

## Dependencies

- gs ([Ghostscript](https://www.ghostscript.com/))

## Usage

`optimpdf [OPTION] [INPUT]*`

**Note**: the '*' symbol mean as many _inputs_ you want.

### Options

#### Help 

Shows help.

`optimpdf -h`

#### Keep original

Keep original PDFs. 

`optimpdf -k [INPUT]*`

### Recursive

Optimeze PDFs recursively in the specified directories.

`optimpdf -r [INPUT]*`

### Inputs

#### Individually

`optimpdf pdf1.pdf pdf2.pdf`

#### Directory

`optimpdf dir`

Self directory do not need to be specified when is alone. 

`optimpdf .` = `optimpdf`

#### Patterns 

`optimpdf Dowloads/foo_**.pdf`

#### Mixed

`optimpdf . Dowloads/pdf1.pdf dir1 pdf2.pdf`

`optimpdf -r Documents/dir1 pdf1.pdf dir2`

**WarningPDF The last one search recursively in 'Documents/dir1' and in 'dir2' also.  
