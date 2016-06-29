export XSLT_INPUTS :=			\
	_src/site/cla.html		\
	_src/site/spec.html		\
	_src/site/design/*

build: tools/rebuild-site .yst.stamp
	tools/rebuild-site

.yst.stamp:
	git clone --depth=1 https://github.com/iphydf/yst
	cabal install yst/yst.cabal
	rm -rf yst
	touch $@

push: build
	git diff --exit-code HEAD `git ls-files | grep -v spec.pdf` || (git commit -a --amend --no-edit && git push --force)
