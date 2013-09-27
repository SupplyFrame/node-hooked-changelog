#!/usr/bin/env bash
checkCmd="bash ./node_modules/node-hooked-changelog/check-for-version.sh"
if [ ! -f ../../.git/hooks/post-commit ]
	then
	echo -e "#!/bin/sh\n" > ../../.git/hooks/post-commit
	chmod +x "../../.git/hooks/post-commit"
fi
if ! grep -Fxq "${checkCmd}" "../../.git/hooks/post-commit"
	then
	echo -e "\nbash ./node_modules/node-hooked-changelog/check-for-version.sh" >> "../../.git/hooks/post-commit"
fi
#sed -i -e "s/^${checkCmd}/SomeParameter A/" "../../.git/hooks/post-commit"
#awk 'BEGIN{FLAG=0}/${checkCmd}/{FLAG=1}END{if(flag==0){for(i=1;i<=NR;i++){print}print ${checkCmd}}}' "../../.git/hooks/post-commit"
#echo "bash ./node_modules/node-hooked-changelog/check-for-version.sh" >> "../../.git/hooks/post-commit"
exit 0