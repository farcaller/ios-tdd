## Implementing code coverage for iOS projects

### Project settings

 * **Generate Test Coverage Files** (*GCC_GENERATE_TEST_COVERAGE_FILES*): YES
 * **Instrument Program Flow** (*GCC_INSTRUMENT_PROGRAM_FLOW_ARCS*): YES
 * Add a fopen hack to your **application** (not the tests bundle), see below.

Note: you do not need to link to profile_rt in recent Xcode!

Consider adding new configuration "Coverage" (based on Debug configuration) for these options.

## Viewing coverage results

[CoverStory](http://code.google.com/p/coverstory/) is a great OS X application for viewing coverage results.

## A hack to make SDK happy

```c
#include <stdio.h>

FILE *fopen$UNIX2003(const char * __restrict, const char * __restrict);
FILE *fopen$UNIX2003( const char *filename, const char *mode )
{
    return fopen(filename, mode);
}

size_t fwrite$UNIX2003(const void * __restrict, size_t, size_t, FILE * __restrict);
size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
    return fwrite(a, b, c, d);
}
```

Add the code above to any .c file that is going to be linked into your application (must be in app itself, not the tests bundle).