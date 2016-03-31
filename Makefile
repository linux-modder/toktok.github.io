export XSLT_INPUTS :=			\
	_src/site/cla.html		\
	_src/site/spec.html		\
	_src/site/design/*

build: tools/rebuild-site
	tools/rebuild-site

push: build
	git diff --exit-code HEAD || (git commit -a --amend --no-edit && git push --force)
