;;; use.el --- Test cases for use tags -*- lexical-binding: t; -*-

;; Copyright (C) 2014 Joris Steyn

;; Author: Joris Steyn <jorissteyn@gmail.com>

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this file; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

(require 'semantic-php)
(require 'ert)

(ert-deftest semantic-php-test-parser-use-statements-simple()
  "Test simple use statements"
  (with-test-buffer
   "use Test;"
   (with-semantic-first-tag
    (should (equal 'type tag-class))
    (should (equal "Test" tag-name)))))

(ert-deftest semantic-php-test-parser-use-statements-with-alias()
  "Test use statements with alias"
  (with-test-buffer
   "use TestA as TestB;"
   (with-semantic-first-tag
    (should (equal 'type tag-class))
    (should (equal "TestB" tag-name))
    (should (equal "TestA" (semantic-tag-name (car tag-members)))))))

(ert-deftest semantic-php-test-parser-use-statements-compound()
  "Test compound use statements"
  (with-test-buffer
   "use TestA, TestB, TestC as TestD;"
   (with-semantic-tags
    (with-semantic-tag (nth 0 tags)
                       (should (equal 'type tag-class))
                       (should (equal "TestA" tag-name)))
    (with-semantic-tag (nth 1 tags)
                       (should (equal 'type tag-class))
                       (should (equal "TestB" tag-name)))
    (with-semantic-tag (nth 2 tags)
                       (should (equal 'type tag-class))
                       (should (equal "TestD" tag-name))
                       (should (equal "TestC" (semantic-tag-name (car tag-members))))))))

(ert-deftest semantic-php-test-parser-use-statements-functions()
  "Test use statements for functions"
  (with-test-buffer
   "use function TestF;"
   (with-semantic-first-tag
    (should (equal 'type tag-class))
    (should (equal "TestF" tag-name))
    (should (equal "function" (plist-get tag-attribs :type))))))

(ert-deftest semantic-php-test-parser-use-statements-constants()
  "Test use statements for constants"
  (with-test-buffer
   "use const TestC;"
   (with-semantic-first-tag
    (should (equal 'type  tag-class))
    (should (equal "TestC" tag-name))
    (should (equal "const" (plist-get tag-attribs :type))))))

(ert-deftest semantic-php-test-parser-use-statements-grouped()
  "Test simple grouped use statements"
  (with-test-buffer
   "use Test\\ { ClassA, ClassB as AliasB };"
   (with-semantic-tags
    (with-semantic-tag (nth 0 tags)
                       (should (equal 'type tag-class))
                       (should (equal "ClassA" tag-name))
                       (should (equal "Test\\ClassA" (semantic-tag-name (car tag-members)))))
    (with-semantic-tag (nth 1 tags)
                       (should (equal 'type tag-class))
                       (should (equal "AliasB" tag-name))
                       (should (equal "Test\\ClassB" (semantic-tag-name (car tag-members))))))))

(ert-deftest semantic-php-test-parser-use-statements-grouped-type()
  "Test grouped use statements with type specifier"
  (with-test-buffer
   "use function Test\\ { funA };"
   (with-semantic-first-tag (should (equal 'type tag-class))
                            (should (equal "funA" tag-name))
                            (should (equal "Test\\funA" (semantic-tag-name (car tag-members))))
                            (should (equal "function" (plist-get tag-attribs :type)))))
  (with-test-buffer
   "use const Test\\ { CONSTA };"
   (with-semantic-first-tag (should (equal 'type tag-class))
                            (should (equal "CONSTA" tag-name))
                            (should (equal "Test\\CONSTA" (semantic-tag-name (car tag-members))))
                            (should (equal "const" (plist-get tag-attribs :type))))))

(ert-deftest semantic-php-test-parser-use-statements-grouped-mixed()
  "Test mixed grouped use statements"
  (with-test-buffer
   "use Test\\ { function funA, const CONSTA, ClassA };"
   (with-semantic-tags
    (with-semantic-tag (nth 0 tags)
                       (should (equal 'type tag-class))
                       (should (equal "funA" tag-name))
                       (should (equal "Test\\funA" (semantic-tag-name (car tag-members))))
                       (should (equal "function" (plist-get tag-attribs :type))))
    (with-semantic-tag (nth 1 tags)
                       (should (equal 'type tag-class))
                       (should (equal "CONSTA" tag-name))
                       (should (equal "Test\\CONSTA" (semantic-tag-name (car tag-members))))
                       (should (equal "const" (plist-get tag-attribs :type))))
    (with-semantic-tag (nth 2 tags)
                       (should (equal 'type tag-class))
                       (should (equal "ClassA" tag-name))
                       (should (equal "Test\\ClassA" (semantic-tag-name (car tag-members))))
                       (should (equal "class" (plist-get tag-attribs :type)))))))

(provide 'test/parser/use)
;;; use.el ends here
