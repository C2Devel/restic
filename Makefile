.PHONY: all clean test restic

all: restic

restic:
	go run build.go

clean:
	rm -f restic

test:
	go test ./cmd/... ./internal/...

PACKAGE = restic
VERSION = $(shell rpm -q --qf "%{version}\n" --specfile $(PACKAGE).spec | head -1)

HEAD_SHA := $(shell git rev-parse --short --verify HEAD)
TAG      := $(shell git show-ref --tags -d | grep $(HEAD_SHA) | \
		git name-rev --tags --name-only $$(awk '{print $2}'))

BUILDID := %{nil}

ifndef TAG
BUILDID := .$(shell date --date="$$(git show -s --format=%ci $(HEAD_SHA))" '+%Y%m%d%H%M').git$(HEAD_SHA)
endif


spec:
	@git cat-file -p $(HEAD_SHA):$(PACKAGE).spec | sed -e 's,@BUILDID@,$(BUILDID),g' > $(PACKAGE).spec

clean-spec:
	@git checkout $(PACKAGE).spec

sources: clean-spec spec
	@git archive --format=tar --prefix=$(PACKAGE)-$(VERSION)/ $(HEAD_SHA) | \
		gzip > $(PACKAGE)-$(VERSION).tar.gz



