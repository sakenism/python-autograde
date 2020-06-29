#!/usr/bin/env bash

set -ue

API_KEY=$1
echo "📝 hello"
echo "⚙️  building enviroment"

GIT_URL=${GITHUB_REPOSITORY}

# download both versions of solutions
STUDENT_SOLUTION="https://github.com/${GIT_URL}"
ORIGINAL_TEMPLATE="https://github.com/${GIT_URL%-task-*}"

echo "⚙️  cloning solutions"
git clone $STUDENT_SOLUTION student
git clone $ORIGINAL_TEMPLATE template
echo "⚙️  cloning finished"
cp -r "template/test" "student/"

# run student tests
cd student
pip install -r requirements.txt

set +e
pytest

last="$?"

send_result(){
	curl -s -X POST "https://learn.alem.school/api/service/grade" -H "x-grade-secret: ${2}" -H "accept: application/json" -H "Content-Type: application/json" -d "{\"lesson\":\"${GIT_URL}\", \"status\": \"${1}\"}"
}

set -e
if [[ $last -eq 0 ]]; then
	echo "✅ ALL TESTS PASSED"
	send_result "done" $API_KEY
else
	echo "🚫 TEST FAILED"
	send_result "failed" $API_KEY
fi

echo "👾 done"
