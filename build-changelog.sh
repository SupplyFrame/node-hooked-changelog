#!/usr/bin/env bash
#if [ $# -eq 1 ]
#	then
#		echo "No arguments specified - must specify a commitish from which to build the log"
#		exit 1
#fi
echo Building CHANGELOG for commits ranging from $1 to $2

#tail -n +2 "CHANGELOG.md" > oldlog.md
function extractParams() {
	json=$1
	shift
	default=$1
	shift
	#construct the regex to match the parameter
	paramRegex="^\["
	while [[ -n "$1" ]]
	do
		paramRegex="${paramRegex}\"$1\""
		shift
		if [ -n "$1" ]
			then
				paramRegex="${paramRegex},"
		fi
	done
	paramRegex="${paramRegex}\]"
	value=$(echo "${json}" | grep "${paramRegex}" | sed "s/${paramRegex}\s\+\"\(.*\)\"/\1/m")
	value=${value:-${default}}
	echo "${value}"
}

function applyTemplateFile() {
	templateFile=$1
	shift
	#loop over parameters and add them as pairs into local scope
	while [[ -n "$1" ]]
	do
		varName=$1
		shift
		if [ -n "$1" ]
			then
				varValue=$1
				shift
				eval ${varName}='"${varValue}"'
		fi
	done

	while IFS=$'\n' read -r line || [[ -n "$line" ]]; do
		eval echo "\"${line}\""
	done < "${templateFile}"
}

function applyTemplate() {
	template=$1
	shift
	#loop over parameters and add them as pairs into local scope
	while [[ -n "$1" ]]
	do
		varName=$1
		shift
		if [ -n "$1" ]
			then
				varValue=$1
				shift
				eval ${varName}='"${varValue}"'
		fi
	done

	while IFS=$'\n' read -r line || [[ -n "$line" ]]; do
		eval echo "\"${line}\""
	done <<< "${template}"
}

#pull log file for given range
log=$(git log $1...$2 --pretty=format:"%H %s")

# filter out merge commits
log=$(echo "${log}" | grep -v '^[a-f0-9]\+\sMerge')

myPath=${3:-./node_modules/node-hooked-changelog}

#find bug url of repository
package=$(${myPath}/node_modules/JSON.sh/JSON.sh -b < package.json)
bugsUrl=$(extractParams "${package}" "" bugs url)
moduleName=$(extractParams "${package}" "" name)
title=$(extractParams "${package}" "${moduleName}" changelog title)
# read url parameters
commitUrlTemplate=$(extractParams "${package}" "" changelog commit-url)
issueUrlTemplate=$(extractParams "${package}" "" changelog issue-url)
if [ -z "$issueUrlTemplate" ] && [ ! -z "$bugsUrl" ]
	then
	issueUrlTemplate="${bugsUrl}/\${issueId}"
fi
# read templates
headerTemplate=$(extractParams "${package}" "${myPath}/header.template" changelog template header)
footerTemplate=$(extractParams "${package}" "${myPath}/footer.template" changelog template footer)
commitTemplate=$(extractParams "${package}" "${myPath}/commit.template" changelog template commit)
issueTemplate=$(extractParams "${package}" "${myPath}/issue.template" changelog template issue)
versionTemplate=$(extractParams "${package}" "${myPath}/version.template" changelog template version)

version="XX.XX.XX"

# apply header template
header=$(applyTemplateFile "${headerTemplate}" moduleName "${moduleName}" title "${title}")
echo "${header}" > CHANGELOG.md
# now replace commit messages with template text
while read -r line
do
#	echo "A new line = $line"

	if [[ $line =~ ^([a-f0-9]+)\ ([0-9]+.[0-9]+.[0-9]+) ]]
		then
		version=${BASH_REMATCH[2]}
		commitId=${BASH_REMATCH[1]}

		commitUrl=$(applyTemplate "${commitUrlTemplate}" commitId "${commitId}")
		
		versionLine=$(applyTemplateFile "${versionTemplate}" commitUrl "${commitUrl}" version "${version}" commitId "${commitId}")
		echo -e "\n${versionLine}" >> CHANGELOG.md

	elif [[ $line =~ ^([a-f0-9]+)\ (.*)$ ]]
		then
		commitId=${BASH_REMATCH[1]}
		commitMessage=${BASH_REMATCH[2]}

		commitUrl=$(applyTemplate "${commitUrlTemplate}" commitId "${commitId}")
		commitLine=$(applyTemplateFile "${commitTemplate}" commitUrl "${commitUrl}" version "${version}" commitId "${commitId}" commitMessage "${commitMessage}")
		
		# replace any occurrances of #NNN issue ids with issueUrlTemplate
		# first extract any issue numbers we can from the string into an array
		issues=( $(echo "${commitLine}" | grep -o '#\([0-9]\+\)') )
		issues=$(echo "${issues[@]}" | sort )
		# now loop over array and replace issue numbers with template string result
		issueLines=()
		for issue in "${issues[@]}"
		do
			:
			issueUrl=$(applyTemplate "${issueUrlTemplate}" issueId "${issue:1}" commitId "${commitId}")
			issueLine=$(applyTemplateFile "${issueTemplate}" issueUrl "${issueUrl}" issueId "${issue:1}" commitId "${commitId}")
			commitLine=${commitLine//${issue}/${issueLine}}
		done
		echo -e "${commitLine}" >> CHANGELOG.md
	fi

done <<< "${log}"
footer=$(applyTemplateFile "${footerTemplate}" moduleName "${moduleName}" title "${title}")
echo "${footer}" >> CHANGELOG.md
exit 0