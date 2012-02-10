## Implementing code coverage for iOS projects

### Project settings

 * **Generate Profiling Code** (*GENERATE_PROFILING_CODE*): YES
 * **Other Linker Flags** (*OTHER_LDFLAGS*): -L/Developer/usr/lib/ -lprofile_rt
 * **Generate Test Coverage Files** (*GCC_GENERATE_TEST_COVERAGE_FILES*): YES
 * **Instrument Program Flow** (*GCC_INSTRUMENT_PROGRAM_FLOW_ARCS*): YES

Consider adding new configuration "Coverage" (based on Debug configuration) for these options.

## Viewing coverage results

[CoverStory](http://code.google.com/p/coverstory/) is a great OS X application for viewing coverage results.
