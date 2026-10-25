# Build downloadable examples from the current app; keep only tutorial stubs separate.
set(example_root "${project_root}/build/tutorial-examples")
file(MAKE_DIRECTORY "${example_root}")

function(replace_tutorial_function path signature indent body)
    file(READ "${path}" content)
    set(start_text "${indent}function ${signature} {")
    string(FIND "${content}" "${start_text}" start)
    if(start LESS 0)
        message(FATAL_ERROR "Tutorial function was not found: ${signature} in ${path}")
    endif()
    string(SUBSTRING "${content}" ${start} -1 tail)
    set(end_text "\n${indent}}")
    string(FIND "${tail}" "${end_text}" finish)
    if(finish LESS 0)
        message(FATAL_ERROR "Tutorial function has no closing brace: ${signature}")
    endif()
    string(LENGTH "${end_text}" end_length)
    math(EXPR remainder "${start} + ${finish} + ${end_length}")
    string(SUBSTRING "${content}" 0 ${start} before)
    string(SUBSTRING "${content}" ${remainder} -1 after)
    file(WRITE "${path}" "${before}${start_text}\n${body}\n${indent}}${after}")
endfunction()

function(replace_tutorial_block path start_text indent replacement)
    file(READ "${path}" content)
    string(FIND "${content}" "${start_text}" start)
    if(start LESS 0)
        message(FATAL_ERROR "Tutorial block not found: ${start_text}")
    endif()
    string(SUBSTRING "${content}" ${start} -1 tail)
    set(end_text "\n${indent}}")
    string(FIND "${tail}" "${end_text}" finish)
    if(finish LESS 0)
        message(FATAL_ERROR "Tutorial block has no closing brace: ${start_text}")
    endif()
    string(LENGTH "${end_text}" end_length)
    math(EXPR remainder "${start} + ${finish} + ${end_length}")
    string(SUBSTRING "${content}" 0 ${start} before)
    string(SUBSTRING "${content}" ${remainder} -1 after)
    file(WRITE "${path}" "${before}${replacement}${after}")
endfunction()

foreach(kind starter solution)
    set(example "${example_root}/${kind}/CarLog")
    file(MAKE_DIRECTORY "${example}/assets")
    file(COPY "${project_root}/qml" DESTINATION "${example}" PATTERN "*.autosave" EXCLUDE)
    file(GLOB_RECURSE editor_backups "${example}/qml/*.autosave")
    if(editor_backups)
        file(REMOVE ${editor_backups})
    endif()
    file(COPY "${project_root}/assets/car.png" DESTINATION "${example}/assets")
    file(COPY "${project_root}/main.cpp" DESTINATION "${example}")
    file(READ "${example}/qml/Main.qml" example_main)
    string(REPLACE "id: storage" "id: storage\n    databaseName: \"CarLogTutorial\"" example_main "${example_main}")
    file(WRITE "${example}/qml/Main.qml" "${example_main}")
    file(READ "${project_root}/CMakeLists.txt" app_cmake)
    string(FIND "${app_cmake}" "# Generate tutorial HTML" docs_start)
    string(FIND "${app_cmake}" "# Executable should" docs_end)
    if(docs_start LESS 0 OR docs_end LESS docs_start)
        message(FATAL_ERROR "Cannot separate the app build from the documentation target.")
    endif()
    string(SUBSTRING "${app_cmake}" 0 ${docs_start} cmake_before)
    string(SUBSTRING "${app_cmake}" ${docs_end} -1 cmake_after)
    file(WRITE "${example}/CMakeLists.txt" "${cmake_before}${cmake_after}")
    file(WRITE "${example}/README.md"
        "# CarLog ${kind}\n\nRequires a configured Felgo desktop kit with Qt 6.8.3.\n"
        "Follow the CarLog tutorial. The starter supplies reusable components;\n"
        "wire the model, build the list and form, then add validation and persistence.\n"
        "The solution contains the current app source.\n")
    if(kind STREQUAL "starter")
        replace_tutorial_block("${example}/qml/Main.qml" "  DataModel {" "  "
            "  DataModel {\n    id: dataModel\n  }")
        replace_tutorial_function("${example}/qml/Main.qml" "onAddFuelRecordRequested()" "    "
            "      // Open the input page when Home requests it.")
        replace_tutorial_function("${example}/qml/Main.qml" "onEditFuelRecordRequested(record)" "    "
            "      // Open the input page with the selected record.")
        replace_tutorial_block("${example}/qml/components/FuelRecordsList.qml" "    ListView {" "    "
            "    ListView {\n      id: recordsView\n      anchors.fill: parent\n      clip: true\n      spacing: dp(12)\n      model: root.records\n    }")
        replace_tutorial_block("${example}/qml/pages/AddFuelRecordPage.qml" "      FuelRecordField {" "      "
            "      // Add a date field that opens the picker sheet.")
        foreach(field_id odometerField fuelField costField)
            replace_tutorial_block("${example}/qml/pages/AddFuelRecordPage.qml" "      FuelRecordField {" "      "
                "      QtObject { id: ${field_id}; property string text: \"\" }")
        endforeach()
        replace_tutorial_function("${example}/qml/pages/AddFuelRecordPage.qml" "submitRecord()" "  "
            "    // Validate the form and dispatch an add or update action.")
        replace_tutorial_function("${example}/qml/logic/FuelRecordValidation.js" "validate(draft)" ""
            "  return {valid: false, errors: {}, record: {}}")
        replace_tutorial_function("${example}/qml/model/DataModel.qml" "saveFuelRecord(draft, recordId)" "  "
            "    fuelRecordSaveFailed({}, qsTr(\"Saving is not connected yet.\"))")
        replace_tutorial_function("${example}/qml/model/DataModel.qml" "deleteFuelRecord(recordId)" "  "
            "    fuelRecordDeleteFailed(qsTr(\"Deletion is not connected yet.\"))")
        replace_tutorial_function("${example}/qml/model/DataModel.qml" "completeOnboarding(name)" "  "
            "    // Save registration after the onboarding screen is built. This starter keeps it only in memory.\n    carName = name.trim()\n    onboardingCompleted = true\n    return true")
        replace_tutorial_function("${example}/qml/model/DataModel.qml" "prepare()" "  "
            "    // Restore saved registration and records on startup.")
        replace_tutorial_block("${example}/qml/pages/OnboardingPage.qml" "    RowLayout {" "    "
            "    // Add the car-name row below the image.")
        replace_tutorial_block("${example}/qml/pages/OnboardingPage.qml" "    StyledButton {" "    "
            "    // Add the registration button below the name row.")
        replace_tutorial_function("${example}/qml/pages/OnboardingPage.qml" "onCovered()" "    "
            "      // Emit registration after the overlay covers the screen.")
        replace_tutorial_block("${example}/qml/pages/HomePage.qml" "    FuelRecordsList {" "    "
            "    Item {\n      Layout.fillWidth: true\n      Layout.fillHeight: true\n      // Display fuel records below the action row.\n    }")
        replace_tutorial_function("${example}/qml/model/DataModel.qml" "storeFuelRecords(records)" "  "
            "    // Save records before updating the list.\n    return false")
        replace_tutorial_function("${example}/qml/pages/StatisticsPage.qml"
            "filterRecords(records, includeAll, fromDate, toDate)" "  "
            "    // Select records for the requested period.\n    return []")
        replace_tutorial_function("${example}/qml/pages/StatisticsPage.qml" "calculateTotals(records)" "  "
            "    // Calculate totals from the filtered records.\n    return {liters: 0, cost: 0}")
    endif()
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar cf "${example_root}/carlog-${kind}.zip" --format=zip CarLog
        WORKING_DIRECTORY "${example_root}/${kind}"
        RESULT_VARIABLE archive_result
    )
    if(NOT archive_result EQUAL 0)
        message(FATAL_ERROR "Cannot package the tutorial ${kind}.")
    endif()
endforeach()
