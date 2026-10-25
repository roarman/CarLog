cmake_minimum_required(VERSION 3.16)

get_filename_component(project_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(output_directory "${project_root}/build/docs/html")
set(log_directory "${project_root}/build/qdoc-logs")

# Resolve at build time so normal app configuration does not require QDoc.
if(NOT QDOC_EXECUTABLE)
    if(NOT "$ENV{QDOC}" STREQUAL "")
        set(QDOC_EXECUTABLE "$ENV{QDOC}")
    elseif(EXISTS "C:/Felgo/Felgo/msvc2022_64/bin/qdoc.exe")
        # The documentation tool is independent of the app's MinGW kit.
        set(QDOC_EXECUTABLE "C:/Felgo/Felgo/msvc2022_64/bin/qdoc.exe")
    else()
        find_program(discovered_qdoc NAMES qdoc)
        set(QDOC_EXECUTABLE "${discovered_qdoc}")
    endif()
endif()
if(NOT QDOC_EXECUTABLE OR NOT EXISTS "${QDOC_EXECUTABLE}")
    message(FATAL_ERROR "QDoc was not found. Set CARLOG_QDOC_EXECUTABLE to its full path.")
endif()

get_filename_component(qdoc_directory "${QDOC_EXECUTABLE}" DIRECTORY)
if(WIN32)
    set(qdoc_path "${qdoc_directory};$ENV{PATH}")
else()
    set(qdoc_path "${qdoc_directory}:$ENV{PATH}")
endif()
file(MAKE_DIRECTORY "${log_directory}")
include("${CMAKE_CURRENT_LIST_DIR}/PrepareExamples.cmake")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "PATH=${qdoc_path}"
        "${QDOC_EXECUTABLE}" "${CMAKE_CURRENT_LIST_DIR}/carlog.qdocconf"
    WORKING_DIRECTORY "${project_root}"
    TIMEOUT 60
    RESULT_VARIABLE qdoc_result
    OUTPUT_FILE "${log_directory}/stdout.log"
    ERROR_FILE "${log_directory}/stderr.log"
)
file(READ "${log_directory}/stdout.log" qdoc_stdout)
file(READ "${log_directory}/stderr.log" qdoc_stderr)
set(qdoc_log "${qdoc_stdout}\n${qdoc_stderr}")
string(STRIP "${qdoc_log}" qdoc_log)
if(qdoc_log)
    message("${qdoc_log}")
endif()
if(NOT "${qdoc_result}" STREQUAL "0")
    message(FATAL_ERROR "QDoc failed: ${qdoc_result}. See ${log_directory}.")
endif()
string(TOLOWER "${qdoc_log}" lowercase_log)
if(lowercase_log MATCHES "(^|[\r\n \t])warning:|(^|[\r\n \t])error:")
    message(FATAL_ERROR "QDoc reported warnings or errors. See ${log_directory}.")
endif()
set(expected_pages index.html)
foreach(page IN LISTS expected_pages)
    if(NOT EXISTS "${output_directory}/${page}")
        message(FATAL_ERROR "QDoc did not generate ${page}.")
    endif()
endforeach()
# Remove obsolete output files from earlier tutorial versions.
foreach(page ko.html complete-source.html build-ui.html save-and-navigate.html animate-transition.html troubleshooting.html)
    file(REMOVE "${output_directory}/${page}")
endforeach()
foreach(old_image final-onboarding final-home part1-onboarding-empty part1-onboarding-valid
        part2-home part2-reset part3-cover part3-reveal)
    file(REMOVE "${output_directory}/images/${old_image}.jpg")
endforeach()
file(MAKE_DIRECTORY "${output_directory}/downloads")
file(COPY "${example_root}/carlog-starter.zip" "${example_root}/carlog-solution.zip"
    DESTINATION "${output_directory}/downloads")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E tar cf "${project_root}/build/CarLog-tutorial.zip" --format=zip html
    WORKING_DIRECTORY "${project_root}/build/docs"
    RESULT_VARIABLE site_archive_result
)
if(NOT site_archive_result EQUAL 0)
    message(FATAL_ERROR "HTML was generated, but packaging the tutorial failed.")
endif()
message(STATUS "Generated English tutorial: ${output_directory}")

if(OPEN_BROWSER)
    set(index_path "${output_directory}/index.html")
    if(WIN32)
        set(browser_command rundll32.exe url.dll,FileProtocolHandler "${index_path}")
    elseif(APPLE)
        set(browser_command open "${index_path}")
    else()
        set(browser_command xdg-open "${index_path}")
    endif()
    execute_process(COMMAND ${browser_command} RESULT_VARIABLE browser_result)
    if(NOT "${browser_result}" STREQUAL "0")
        message(FATAL_ERROR "HTML was generated, but opening the browser failed: ${browser_result}")
    endif()
    message(STATUS "Opened tutorial: ${index_path}")
endif()
