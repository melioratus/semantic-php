;;; context.el --- Test context functions

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

;; TODO: context analysis quickly becomes a mess, need a proper way of
;; testing this.

(require 'semantic-php)
(require 'ert)

(ert-deftest semantic-php-test-context-simple ()
  "Test context analysis: simple classes"
  (with-saved-test-buffer
   "
class A {
    function a() {}
    function b() {
        $this->
    }
}
"
   (search-forward "$this->")
   (message (pp-to-string
             (semantic-analyze-possible-completions (point))
             ))))

(ert-deftest semantic-php-test-context-scope ()
  :expected-result :failed
  "Test scope calculation"
  (with-saved-test-buffer
   "
class Test extends TestA {
    public function test() {
        inMethod;
    }

    public function test2() {}
}

class TestA {
    public function test2() {}
}
"
   (search-forward "inMethod")

   (let* ((scope (semantic-calculate-scope))
          (tag (oref scope tag))
          (parents (oref scope parents))
          (parentinheritance (oref scope parentinheritance)))
     (should (equal "test" (semantic-tag-name tag)))
     (should (equal "Test" (semantic-tag-name (car parents))))
     (should (equal "TestA" (semantic-tag-name (caar parentinheritance)))))))

(provide 'test/context)
;; context.el ends here