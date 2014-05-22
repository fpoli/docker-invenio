#!/bin/bash

echo "[*] Unit tests"
nosetests /opt/invenio/lib/python/invenio/*_unit_tests.py

echo "[*] Regression tests"
nosetests /opt/invenio/lib/python/invenio/*_regression_tests.py
