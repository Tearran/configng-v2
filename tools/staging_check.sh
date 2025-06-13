#!/bin/bash
set -e

fail=0

# 1. Check for test_*.sh in ./staging/
#echo "Checking for test_*.sh in ./staging/..."
if compgen -G "./staging/test_*.sh" > /dev/null; then
	echo "PASS: Found test_*.sh"
else
	echo "FAIL: No test_*.sh scripts found in ./staging/"
	fail=1
fi

# 2. Check for src_*.sh in ./staging/
#echo "Checking for src_*.sh in ./staging/..."
if compgen -G "./staging/src_*.sh" > /dev/null; then
	echo "PASS: Found src_*.sh"
else
	echo "FAIL: No src_*.sh scripts found in ./staging/"
	fail=1
fi

# 3. Check for meta_*.conf in ./staging/
#echo "Checking for meta_*.conf in ./staging/..."
if compgen -G "./staging/meta_*.conf" > /dev/null; then
	echo "PASS: Found meta_*.conf"
else
	echo "FAIL: No meta_*.conf found in ./staging/"
	fail=1
fi

# 4. Optional: Advise on docs
#echo "Checking for doc_*.md in ./staging/..."
if compgen -G "./staging/doc_*.md" > /dev/null; then
	echo "PASS: Found doc_*.md"
else
	echo "WARNING: No doc_*.md Consider adding extra info to ./staging/doc_*.md"
fi

# Summary
if [ "$fail" -eq 0 ]; then
	echo "PASS: All required files are present in ./staging/"
else
	echo "FAIL: One or more required files missing in ./staging/"
fi

exit $fail