# Testsuite tests as CTest tests.
#
# Included from the clusterscheduler project the same way gcs-extensions is:
#
#    set(PROJECT_TESTSUITE "None" CACHE STRING "directory of the testsuite")
#    if (NOT PROJECT_TESTSUITE STREQUAL "None")
#       add_subdirectory(${PROJECT_TESTSUITE}/tools "testsuite")
#    endif ()
#
# Off by default: whoever does not set PROJECT_TESTSUITE sees none of this.
#
# The point is the IDE. CLion builds its test tree from the CMake model, which
# is why the 73 unit tests show up there without any run configuration being
# checked in. Adding the testsuite units to the same model puts them in the same
# tree -- single test, filter by label, rerun the failures, all from the IDE.
#
# The list is generated at configure time rather than checked in, because a
# checkout can add and remove tests. A stale list does not merely mislead, it
# breaks with "path not found in checktree". The scan costs about 0.15 s, so it
# rides along with the CMake reload you would do anyway.

set(TESTSUITE_LINE "" CACHE STRING
    "release line whose testsuite to register (90x, 91x, 92x; empty = off)")
set(TESTSUITE_RUNNERS "8" CACHE STRING
    "number of parallel test clusters to distribute over")
set(TESTSUITE_FILTER "" CACHE STRING
    "regex on the test name; only matching tests are registered (empty = all)")

if (NOT TESTSUITE_LINE STREQUAL "")
   set(_scan "${CMAKE_CURRENT_SOURCE_DIR}/gcs-testscan")
   set(_out "${CMAKE_CURRENT_BINARY_DIR}")

   # Restrict here rather than with ctest's -R or -L. Those filter at invocation
   # time, and ctest renumbers whatever survives -- while an IDE re-running a
   # single test from its results tree passes the index from the full list. The
   # two together find nothing, or silently the wrong test. Registering only the
   # wanted tests keeps both lists identical, so single tests stay re-runnable.
   # Switching sets is then a CMake profile, not a run configuration.
   set(_filter "")
   if (NOT TESTSUITE_FILTER STREQUAL "")
      set(_filter --filter "${TESTSUITE_FILTER}")
   endif ()

   execute_process(
      COMMAND "${_scan}" "${TESTSUITE_LINE}" split "${TESTSUITE_RUNNERS}"
              --out "${_out}" ${_filter}
      RESULT_VARIABLE _rc
      OUTPUT_VARIABLE _log
      ERROR_VARIABLE  _log)

   if (NOT _rc EQUAL 0)
      # Not fatal on purpose: a missing runner setup must not stop the product
      # build. Whoever wants the testsuite tests will see why they are absent.
      message(WARNING "testsuite: gcs-testscan failed, no tests registered\n${_log}")
   else ()
      message(STATUS "testsuite: registering tests of line ${TESTSUITE_LINE} "
                     "over ${TESTSUITE_RUNNERS} runners")

      # The tests declare RESOURCE_GROUPS, so ctest needs the resource
      # specification to hand each of them an exclusive cluster. Setting the
      # variable here rather than expecting --resource-spec-file on the command
      # line is what makes the tests runnable straight from an IDE: the run
      # configurations an IDE generates from the CMake model pass no extra
      # ctest arguments, and without the spec every test fails immediately.
      set(CTEST_RESOURCE_SPEC_FILE "${_out}/ts_cluster.json"
          CACHE FILEPATH "resource specification for the testsuite clusters" FORCE)

      # The generated file is plain add_test/set_tests_properties, so including
      # it is all that is needed.
      include("${_out}/CTestTestfile.cmake")
   endif ()
endif ()
