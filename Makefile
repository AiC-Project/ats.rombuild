
.ccache:
	mkdir .ccache && chown $(shell logname | xargs id -u).$(shell logname | xargs id -g) .ccache

bin/repo:
	curl -s https://storage.googleapis.com/git-repo-downloads/repo -o bin/repo && chmod 755 bin/repo

.PHONY: rom-init-mirror
rom-init-mirror: | bin/repo
	mkdir -p src/aic-kitkat && cd src/aic-kitkat && $(shell pwd)/bin/repo init -q -u https://github.com/AiC-Project/manifest.git -b aic-kitkat --reference=$(shell pwd)/src/mirror
	mkdir -p src/aic-lollipop && cd src/aic-lollipop && $(shell pwd)/bin/repo init -q -u https://github.com/AiC-Project/manifest.git -b aic-lollipop --reference=$(shell pwd)/src/mirror

.PHONY: rom-init-nomirror
rom-init-nomirror: | bin/repo
	mkdir -p src/aic-kitkat && cd src/aic-kitkat && $(shell pwd)/bin/repo init -q -u https://github.com/AiC-Project/manifest.git -b aic-kitkat
	mkdir -p src/aic-lollipop && cd src/aic-lollipop && $(shell pwd)/bin/repo init -q -u https://github.com/AiC-Project/manifest.git -b aic-lollipop

.PHONY: rom-sync-all
rom-sync-all:
	$(shell pwd)/bin/rom-sync src/aic-kitkat
	$(shell pwd)/bin/rom-sync src/aic-lollipop

.PHONY: docker-rombuilders
docker-rombuilders:
	docker build --build-arg USER_ID=$(shell logname | xargs id -u) --build-arg GROUP_ID=$(shell logname | xargs id -g) -t aic.rombuilder-4.4.4 docker/4.4.4
	docker build --build-arg USER_ID=$(shell logname | xargs id -u) --build-arg GROUP_ID=$(shell logname | xargs id -g) -t aic.rombuilder-5.1.1 docker/5.1.1

.PHONY: rom-build-all
rom-build-all: docker-rombuilders | .ccache
	bin/rom-build src/aic-kitkat gobyp android/aic-kitkat/gobyp
	bin/rom-build src/aic-kitkat gobyt android/aic-kitkat/gobyt
	bin/rom-build src/aic-lollipop gobyp android/aic-lollipop/gobyp
	bin/rom-build src/aic-lollipop gobyt android/aic-lollipop/gobyt

.PHONY: android-images.tar
android-images.tar:
	tar cvf android-images.tar android

