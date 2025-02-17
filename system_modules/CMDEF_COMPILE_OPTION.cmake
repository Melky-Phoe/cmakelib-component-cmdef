## Main
#
# Functions for managing Build options
#
#

IF(DEFINED CMDEF_COMPILE_OPTION_MODULE)
	RETURN()
ENDIF()
SET(CMDEF_COMPILE_OPTION_MODULE 1)

FIND_PACKAGE(CMLIB)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_BUILD_TYPE.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_ADD_LIBRARY.cmake)



##
# Add build option for given BUILD type.
#
# ALL is list of compile options which will be add
# to each BUILD_TYPE
#
# BUILD_TYPE_UPPERCASE is uppercase version of build_type
# from BUILD_TYPE list.
#
# LANG - array, If specified must be on CMDEF_SUPPORTED_LANG_LIST.
# If not specified no exact languege is select
#
# Each definition is passed to ADD_COMPILE_OPTIONS
# by generator_expression $<<CONFIG:build_type>:${option}>
#
# <function>(
#		[LANG <lang> M]
#		[ALL <compile_options>]
#		[<BUILD_TYPE_UPERCASE> <compile_options>]{1,}
# )
#
MACRO(CMDEF_COMPILE_OPTIONS)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			LANG ALL
			${CMDEF_BUILD_TYPE_LIST_UPPERCASE}
		P_ARGN ${ARGN}
	)

	IF(DEFINED __LANG)
		CMUTIL_TRAIT_IN_ARRAY(VALUES ${__LANG} ARRAY CMDEF_SUPPORTED_LANG_LIST
			DESCRIPTION "Unsupported language")
	ENDIF()

	FOREACH(build_type IN LISTS CMDEF_BUILD_TYPE_LIST_UPPERCASE)
		SET(build_type_var __${build_type})
		IF(DEFINED __ALL)
			LIST(APPEND ${build_type_var} ${__ALL})
		ENDIF()
		IF(NOT DEFINED ${build_type_var})
			CONTINUE()
		ENDIF()
		FOREACH(option IN LISTS ${build_type_var})
			IF(DEFINED __LANG)
				SET(condition $<AND:$<COMPILE_LANGUAGE:${__LANG}>,$<CONFIG:${build_type}>>)
				SET(compile_options $<${condition}:${option}>)
				ADD_COMPILE_OPTIONS(${compile_options})
			ELSE()
				ADD_COMPILE_OPTIONS($<$<CONFIG:${build_type}>:${option}>)
			ENDIF()
		ENDFOREACH()
		UNSET(${build_type_var})
	ENDFOREACH()
ENDMACRO()



##
#
# BUILD_TYPE_UPPERCASE is uppercase version of build_type
# from BUILD_TYPE list.
#
# ALL is list of compile options which will be add
# to each BUILD_TYPE
#
# LANG - array, if specified must be one of CMDEF_SUPPORTED_LANG_LIST.
# If not specified no exact languege is select
#
# Each definition is passed to ADD_COMPILE_OPTIONS
# by generator_expression $<<CONFIG:build_type>:${option}>
#
# VISIBLITY is passed to visiblity section of TARGET_LINK_OPTIONS.
# If no visiblity specified than visiblity is omitted
#
# <function> (
#		TARGET <target>
#		[LANG <lang_list>]
#		[ALL <compile_options>]
#		[<BUILD_TYPE_UPPERCASE> <link_options>]{1,}
#		[VISIBLITY <INTERFACE|PUBLIC|PRIVATE>]
# )
#
FUNCTION(CMDEF_COMPILE_OPTIONS_TARGET)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			LANG ALL
			${CMDEF_BUILD_TYPE_LIST_UPPERCASE}
		ONE_VALUE
			TARGET
			VISIBLITY
		REQUIRED
			TARGET
			VISIBLITY
		P_ARGN ${ARGN}
	)

	IF(DEFINED __LANG)
		CMUTIL_TRAIT_IN_ARRAY(VALUES ${__LANG} ARRAY CMDEF_SUPPORTED_LANG_LIST
			DESCRIPTION "Unsupported language")
	ENDIF()

	SET(original_target_name ${__TARGET})

	FOREACH(build_type IN LISTS CMDEF_BUILD_TYPE_LIST_UPPERCASE)
		SET(build_type_var __${build_type})
		IF(DEFINED __ALL)
			LIST(APPEND ${build_type_var} ${__ALL})
		ENDIF()
		IF(NOT DEFINED ${build_type_var})
			CONTINUE()
		ENDIF()
		IF(DEFINED __LANG)
			SET(option ${${build_type_var}})
			SET(condition $<AND:$<COMPILE_LANGUAGE:${__LANG}>,$<CONFIG:${build_type}>>)
			SET(compile_options $<${condition}:${option}>)
			TARGET_COMPILE_OPTIONS(${original_target_name} ${__VISIBLITY} ${compile_options})
		ELSE()
			TARGET_COMPILE_OPTIONS(${original_target_name} ${__VISIBLITY} $<$<CONFIG:${build_type}>:${${build_type_var}}>)
		ENDIF()
	ENDFOREACH()
ENDFUNCTION()

