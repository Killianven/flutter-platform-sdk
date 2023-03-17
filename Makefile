WORKING_DIR := $(shell pwd)

fetch-submodules:
	$(shell export PUB_CACHE=./pub-cache)
	flutter pub get
	cd ~/.pub-cache/git/nrf_mesh_plugin* && \
		echo $(shell pwd) && \
		git submodule update --init --recursive

build-ios: fetch-submodules
	cd $(WORKING_DIR)/example/ && \
		flutter build ios

run-ios: fetch-submodules
	cd $(WORKING_DIR)/example/ && \
		flutter run

build-apk: fetch-submodules
	cd $(WORKING_DIR)/example/ && \
		flutter build apk

run-android: fetch-submodules
	cd $(WORKING_DIR)/example/ && \
		flutter run 
