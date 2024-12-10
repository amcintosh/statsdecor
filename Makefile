.PHONY: clean-pyc clean-build docs clean install lint test test-all
.PHONY: coverage release dist

ifeq ($(BRANCH_NAME),)
BRANCH_NAME="$$(git rev-parse --abbrev-ref HEAD)"
endif

help:
	@echo "install - Install development dependencies."
	@echo "clean - Remove all build, test, coverage and Python artifacts."
	@echo "clean-build - Remove build artifacts."
	@echo "clean-pyc - Remove Python bytecode."
	@echo "clean-test - Remove test and coverage artifacts."
	@echo "lint - Check style with flake8."
	@echo "test - Run tests quickly with the default Python."
	@echo "test-all - Run tests on every Python version with tox."
	@echo "release - Package and upload a release."
	@echo "dist - Create tar and whl files."

install: requirements-dev.txt requirements.txt
	pip install -r requirements-dev.txt

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -f coverage.xml
	rm -f junit.xml

lint:
	flake8 statsdecor --count --show-source --statistics
	flake8 tests --count --show-source --statistics

test:
	py.test --junitxml=junit.xml \
		--cov=statsdecor \
		--cov-branch \
		--cov-report=xml:coverage.xml \
		--cov-config=setup.cfg \
		tests
	coverage report -m

test-all:
	tox

tag:
	@if [ "$(BRANCH_NAME)" != "main" ]; then \
		echo "You must be on main to update the version"; \
		exit 1; \
	fi;
	@if [ "$(VERSION_PART)" = '' ]; then \
		echo "Must specify VERSION_PART to bump (major, minor, patch)."; \
		exit 1; \
	fi;
	pip install bumpversion
	git stash && \
	git fetch --all && \
	git reset --hard origin/main && \
	bumpversion $(VERSION_PART) && \
	git push origin --tags && \
	git push origin main && \
	git stash pop
