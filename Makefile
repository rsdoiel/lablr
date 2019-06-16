#
# Simple Makefile for conviently testing, building and 
# deploying experiment programs.
#
PROJECT = lablr

VERSION = $(shell grep -m 1 'Version =' $(PROJECT).go | cut -d\`  -f 2)

BRANCH = $(shell git branch | grep '* ' | cut -d\  -f 2)

PKGASSETS = $(shell which pkgassets)

PROJECT_LIST = lablr

OS = $(shell uname)

EXT = 
ifeq ($(OS), Windows)
	EXT = .exe
endif


lablr$(EXT): bin/lablr$(EXT)

bin/lablr$(EXT): lablr.go cmd/lablr/lablr.go
	go build -o bin/lablr$(EXT) cmd/lablr/lablr.go

build: $(PROJECT_LIST)

install: 
	env GOBIN=$(GOPATH)/bin go install cmd/lablr/lablr.go

install-man:
	mkdir -p $(GOPATH)/man/man1
	$(GOPATH)/bin/lablr -generate-manpage | nroff -Tutf8 -man > $(GOPATH)/man/man1/lablr.1

liblablr: FORCE
	cd liblablr && $(MAKE)

test: clean bin/lablr$(EXT)
	go test

cleanweb:
	if [ -f index.html ]; then rm *.html; fi

clean: 
	if [ -d bin ]; then rm -fR bin; fi
	if [ -d dist ]; then rm -fR dist; fi
	if [ -d man ]; then rm -fR man; fi
	if [ -d testdata ]; then rm -fR testdata; fi

man: build
	mkdir -p man/man1
	bin/lablr -generate-manpage | nroff -Tutf8 -man > man/man1/lablr.1

dist/linux-amd64:
	mkdir -p dist/bin
	env  GOOS=linux GOARCH=amd64 go build -o dist/bin/lablr cmd/lablr/lablr.go
	cd dist && zip -r $(PROJECT)-$(VERSION)-linux-amd64.zip README.md LICENSE INSTALL.md bin/*
	rm -fR dist/bin

dist/windows-amd64:
	mkdir -p dist/bin
	env  GOOS=windows GOARCH=amd64 go build -o dist/bin/lablr.exe cmd/lablr/lablr.go
	cd dist && zip -r $(PROJECT)-$(VERSION)-windows-amd64.zip README.md LICENSE INSTALL.md bin/*
	rm -fR dist/bin

dist/macosx-amd64:
	mkdir -p dist/bin
	env  GOOS=darwin GOARCH=amd64 go build -o dist/bin/lablr cmd/lablr/lablr.go
	cd dist && zip -r $(PROJECT)-$(VERSION)-macosx-amd64.zip README.md LICENSE INSTALL.md bin/*
	rm -fR dist/bin

dist/raspbian-arm7:
	mkdir -p dist/bin
	env  GOOS=linux GOARCH=arm GOARM=7 go build -o dist/bin/lablr cmd/lablr/lablr.go
	cd dist && zip -r $(PROJECT)-$(VERSION)-raspbian-arm7.zip README.md LICENSE INSTALL.md bin/*
	rm -fR dist/bin

distribute_docs:
	if [ -d dist ]; then rm -fR dist; fi
	mkdir -p dist
	cp -v README.md dist/
	cp -v LICENSE dist/
	cp -v INSTALL.md dist/

release: clean distribute_docs dist/linux-amd64 dist/windows-amd64 dist/macosx-amd64 dist/raspbian-arm7 FORCE

status:
	git status

save:
	if [ "$(msg)" != "" ]; then git commit -am "$(msg)"; else git commit -am "Quick Save"; fi
	git push origin $(BRANCH)

website: page.tmpl README.md nav.md INSTALL.md LICENSE css/site.css
	./mk-website.py

publish:
	./mk-website.py
	./publish.bash

FORCE:
