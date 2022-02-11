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
