#!/usr/bin/make -f

SHELL := /bin/bash  # force use of Bash
INTERACTIVE=true
BATS=./test/libs/bats/bin/bats

.PHONY: install
install:
	sudo add-apt-repository ppa:jonathonf/ffmpeg-4 --yes
	sudo add-apt-repository ppa:duggan/bats --yes
	sudo apt-get update --quiet --quiet
	sudo apt-get install \
		--yes \
		--no-install-recommends \
		--no-install-suggests \
		--quiet --quiet \
		bats \
		ffmpeg

.PHONY: install-subtitle-editor
install-subtitle-editor:
	sudo add-apt-repository ppa:alex-p/aegisub --yes
	sudo apt-get update --quiet --quiet
	sudo apt-get install  \
		--yes \
		--no-install-recommends \
		--no-install-suggests \
		--quiet --quiet \
		aegisub

.PHONY: install-uploader
install-uploader:
	curl https://github.com/yarl/pattypan/releases/download/v18.02/pattypan.jar \
		--output pattypan.jar \
		--location
	apt-get install \
		--yes \
		--no-install-recommends \
		--no-install-suggests \
		--quiet --quiet \
	openjfx \
	openjdk-8-jre \
	openjdk-8-jre-headless

.PHONY: test
test:
	${BATS} --pretty ./test/*.test.bash

.PHONY: extract-timing
extract-timing:
	time bash ./scripts/extract-timing.bash \
		./data/partie-1:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.ass
	time bash ./scripts/extract-timing.bash \
		./data/partie-2:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.ass

.PHONY: extract-in-hd
extract-in-hd:
	if [[ ! -d videos-hd ]]; then mkdir videos-hd; fi
	bash ./scripts/extract-in-hd.bash \
		./data/partie-1:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.webm \
		./data/partie-1:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.tsv
	bash ./scripts/extract-in-hd.bash \
		./data/partie-2:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.webm \
		./data/partie-2:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.tsv

.PHONY: encode-for-mobile
encode-for-mobile:
	bash ./scripts/encode-for-mobile.bash \
		./data/partie-1:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.webm \
		./data/partie-1:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.tsv
	bash ./scripts/encode-for-mobile.bash \
		./data/partie-2:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.webm \
		./data/partie-2:-Apprendre-300-mots-du-quotidien-en-LSF.jauvert-laura.hd.tsv

.PHONY: build
build: extract-timing encode-for-mobile
	time bash ./scripts/create-json-dictionary.bash

.PHONY: update-dictionary
update-dictionary:
	bash ./scripts/create-json-dictionary.bash
	cp ./vocabulaire.json ../lsf/src/assets/

