XSLT_INPUTS :=				\
	_src/site/cla.html		\
	_src/site/spec.html		\
	_src/site/design/*

build:
	cp ../tox-spec/spec.md _src/content/spec.md
#	cp ../tox-spec/rust.css _src/files/css/
	cp -a ../tox-spec/img _src/files/
	cd _src && yst
	for f in $(XSLT_INPUTS); do			\
	  xsltproc -o $$f _src/xsl/transform.xsl $$f;	\
	done
	for f in _src/site/*; do			\
	  rm -rf `echo $$f | sed -e 's|_src/site/||'`;	\
	done
	mv _src/site/* .
	rmdir _src/site
