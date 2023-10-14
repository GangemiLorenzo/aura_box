THIS_FILE := $(lastword $(MAKEFILE_LIST))

help:
	@make -pRrq  -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

unit:
	@flutter test

cov:
	@flutter test --coverage && lcov --remove coverage/lcov.info '**/*.g.dart' -o coverage/lcov.info && genhtml coverage/lcov.info --output=coverage && open coverage/index.html

clean:
	@rm -rf pubspec.lock
	@flutter clean

format:
	@dart format .

lint:
	@dart analyze .

clean-pod:
	cd ios && pod deintegrate && pod update && cd ..