VERSION?=minor
.PHONY: release minor
release minor: $(VIRTUAL_ENV)
	bump2version $(VERSION)
	@git push
	@git push --tags

.PHONY: patch
patch:
	make release VERSION=patch

.PHONY: major
major:
	make release VERSION=major

.PHONY: test t
LUA_PATH := $(LUA_PATH):$(CURDIR)
test t:
	rm -f spec/hashmap
	vusted --lpath="./?.lua;./?/?.lua;./?/init.lua" 
