#!/bin/bash

set -euo pipefail


SNIFF=1
WP_VERSION=4.9.9
WP_MULTISITE=1
PHP_VERSION=7.3

DIR=$(basename $(pwd))

if [ "$DIR" != "bin" ]; then
  echo "You must run this script from the bin directory."
  exit 1
fi

cd ..

# Install phpunit 7.x as WordPress does not support 8.x yet
if [[ "$PHP_VERSION" == "5.6" ]]; then PHPUNIT_VERSION=5.7.9; else PHPUNIT_VERSION=7.5.9; fi
wget https://phar.phpunit.de/phpunit-$PHPUNIT_VERSION.phar -O /tmp/phpunit; chmod +x /tmp/phpunit
# Install WordPress PHPUnit tests
bash bin/install-wp-tests.sh wordpress_test root '' localhost $WP_VERSION

# Install PHP_CodeSniffer with a specific version defined so that devs and Travis-CI will have exactly same standards
if [[ "$SNIFF" == "1" ]]; then export PHPCS_DIR=/tmp/phpcs; export PHPCS_VERSION=3.3.2; fi
if [[ "$SNIFF" == "1" ]]; then export WP_SNIFFS_DIR=/tmp/wp-sniffs; export WP_SNIFFS_VERSION=2.1.0; fi
if [[ "$SNIFF" == "1" ]]; then export SECURITY_SNIFFS_DIR=/tmp/security-sniffs; export SECURITY_SNIFFS_VERSION=2.0.0; fi
if [[ "$SNIFF" == "1" ]]; then export PHP_COMPATIBILITY_SNIFFS_DIR=/tmp/compatibility-sniffs; export PHP_COMPATIBILITY_SNIFFS_VERSION=9.1.1; fi

# Install PHP_CodeSniffer.
if [[ "$SNIFF" == "1" ]] && [[ ! -f $PHPCS_DIR ]]; then
  rm -rf $PHPCS_DIR
  wget https://github.com/squizlabs/PHP_CodeSniffer/archive/$PHPCS_VERSION.tar.gz -O $PHPCS_VERSION.tar.gz
  tar -xf $PHPCS_VERSION.tar.gz
  mv PHP_CodeSniffer-$PHPCS_VERSION $PHPCS_DIR
fi

# Install WordPress Coding Standards.
if [[ "$SNIFF" == "1" ]] && [[ ! -f $WP_SNIFFS_DIR ]]; then
  rm -rf $WP_SNIFFS_DIR
  wget https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards/archive/$WP_SNIFFS_VERSION.tar.gz -O $WP_SNIFFS_VERSION.tar.gz
  tar -xf $WP_SNIFFS_VERSION.tar.gz
  mv WordPress-Coding-Standards-$WP_SNIFFS_VERSION $WP_SNIFFS_DIR
fi

# Install PHPCS Security Audit.
if [[ "$SNIFF" == "1" ]] && [[ ! -f $SECURITY_SNIFFS_DIR ]]; then
  rm -rf $SECURITY_SNIFFS_DIR
  wget https://github.com/FloeDesignTechnologies/phpcs-security-audit/archive/$SECURITY_SNIFFS_VERSION.tar.gz -O $SECURITY_SNIFFS_VERSION.tar.gz
  tar -xf $SECURITY_SNIFFS_VERSION.tar.gz
  mv phpcs-security-audit-$SECURITY_SNIFFS_VERSION $SECURITY_SNIFFS_DIR
fi

# Install PHP Compatibility.
if [[ "$SNIFF" == "1" ]]  && [[ ! -f $PHP_COMPATIBILITY_SNIFFS_DIR ]]; then
  rm -rf $PHP_COMPATIBILITY_SNIFFS_DIR
  wget https://github.com/PHPCompatibility/PHPCompatibility/archive/$PHP_COMPATIBILITY_SNIFFS_VERSION.tar.gz -O $PHP_COMPATIBILITY_SNIFFS_VERSION.tar.gz
  tar -xf $PHP_COMPATIBILITY_SNIFFS_VERSION.tar.gz
  mv PHPCompatibility-$PHP_COMPATIBILITY_SNIFFS_VERSION $PHP_COMPATIBILITY_SNIFFS_DIR
fi

# Set install path for sniffs.
if [[ "$SNIFF" == "1" ]]; then $PHPCS_DIR/bin/phpcs --config-set installed_paths $WP_SNIFFS_DIR,$SECURITY_SNIFFS_DIR,$PHP_COMPATIBILITY_SNIFFS_DIR; fi

# Show installed sniffs
if [[ "$SNIFF" == "1" ]]; then ${PHPCS_DIR}/bin/phpcs -i; fi
