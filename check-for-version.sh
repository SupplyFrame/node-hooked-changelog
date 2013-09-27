#!/bin/sh
if [ -f .changelog.lock ]
	then
		echo "Changelog in progress, exiting hook."
		exit 0
fi
msg=$(git log -1 --skip 0 HEAD --pretty=format:"%H %s")
if [[ $msg =~ ^([a-f0-9]+)\ ([0-9]+\.[0-9]+\.[0-9]+)$ ]]
	then
		touch .changelog.lock
		# remember to use new commit, not tag, since tag isn't created yet oddly!
		newCommit=${BASH_REMATCH[1]}
		# find old tag before this one
		firstTag=$(git tag --list "v[0-9]*\.[0-9]*\.[0-9]*" | sort -V | head -1)
		#lastTag=$(git tag --list "v[0-9]*\.[0-9]*\.[0-9]*" | sed -n 'x;$p')
		$(./node_modules/node-hooked-changelog/build-changelog.sh "${firstTag}" "${newCommit}")
		git add CHANGELOG.md
		git commit --amend -C HEAD
		rm -rf .changelog.lock
		exit 0
fi
exit 0