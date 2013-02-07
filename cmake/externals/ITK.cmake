function(ITK_project)

    if (DEFINED ITK_DIR AND NOT EXISTS ${ITK_DIR})
        message(FATAL_ERROR "ITK_DIR variable is defined but corresponds to non-existing directory")
    endif()

    ParseProjectArguments(ITK itkp "" "GIT" ${ARGN})

    set(MD5_CHECK)
    if (${itkp_GIT})
        set(location_args GIT_REPOSITORY "${git_protocol}://itk.org/ITK.git")
        if (NOT "${revision}" STREQUAL "")
            set(location_args ${location_args} GIT_TAG ${revision})
        endif()
    else()
        set(revision 3.20.1)
        if (NOT "${itkp_REVISION}" STREQUAL "") 
            set(revision ${itkp_REVISION})
        endif()

        string(REGEX REPLACE "[.][0-9]*$" "" short_rev ${revision})

        set(location_args URL "http://sourceforge.net/projects/itk/files/itk/${short_rev}/InsightToolkit-${revision}.tar.gz")

        if ("${revision}" STREQUAL "3.20.1")
            set(MD5_CHECK URL_MD5 "90342ffa78bd88ae48b3f62866fbf050")
        elseif ("${revision}" STREQUAL "4.3.1")
            set(MD5_CHECK URL_MD5 "de443086f1f5dd27c3639644cebe488c")
        endif()
    endif()

    set(ITK_enabling_variable ITK_LIBRARIES)

    set(${ITK_enabling_variable}_LIBRARY_DIRS ITK_LIBRARY_DIRS)
    set(${ITK_enabling_variable}_INCLUDE_DIRS ITK_INCLUDE_DIRS)
    set(${ITK_enabling_variable}_FIND_PACKAGE_CMD ITK)

    set(ep_project_include_arg)
    if (CTEST_USE_LAUNCHERS)
        set(ep_project_include_arg
            "-DCMAKE_PROJECT_ITK_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake")
    endif()

    if (NOT DEFINED location)
        set(location ${location_args} ${MD5_CHECK})
    endif()

    ExternalProject_Add(ITK
        PREFIX ITK
        ${location}
        UPDATE_COMMAND ""
        INSTALL_COMMAND ""
        CMAKE_GENERATOR ${gen}
        CMAKE_CACHE_ARGS
            ${ep_common_cache_args}
            ${ep_project_include_arg}
            -DBUILD_EXAMPLES:BOOL=OFF
            -DBUILD_TESTING:BOOL=OFF
            -DBUILD_SHARED_LIBS:BOOL=ON
            -DITK_USE_REVIEW:BOOL=ON
            -DITK_USE_REVIEW_STATISTICS:BOOL=ON
            -DITK_INSTALL_NO_DEVELOPMENT:BOOL=ON
    )
    set(ITK_DIR ${CMAKE_BINARY_DIR}/ITK/src/ITK-build PARENT_SCOPE)

endfunction()
