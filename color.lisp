;;; IMAGO library
;;; Color operations
;;;
;;; Copyright (C) 2004  Matthieu Villeneuve (matthieu.villeneuve@free.fr)
;;;
;;; The authors grant you the rights to distribute
;;; and use this software as governed by the terms
;;; of the Lisp Lesser GNU Public License
;;; (http://opensource.franz.com/preamble.html),
;;; known as the LLGPL.


(in-package :imago)

(declaim (inline make-gray))
(defun make-gray (intensity &optional (alpha #xff))
  (logior (ash alpha 8) intensity))

(defun gray-intensity (gray)
  (the (unsigned-byte 8) (ldb (byte 8 0) gray)))

(defun gray-alpha (gray)
  (the (unsigned-byte 8) (ldb (byte 8 8) gray)))

(defun invert-gray (gray)
  (logior (lognot (logand gray #x00ff))
          (logand gray #xff00)))

(declaim (inline make-color))
(defun make-color (r g b &optional (alpha #xff))
  (logior (ash alpha 24) (ash r 16) (ash g 8) b))

(defun color-red (color)
  (the (unsigned-byte 8) (ldb (byte 8 16) color)))

(defun color-green (color)
  (the (unsigned-byte 8) (ldb (byte 8 8) color)))

(defun color-blue (color)
  (the (unsigned-byte 8) (ldb (byte 8 0) color)))

(defun color-alpha (color)
  (the (unsigned-byte 8) (ldb (byte 8 24) color)))

(defun color-rgb (color)
  (values (color-red color)
          (color-green color)
          (color-blue color)))

(defun color-argb (color)
  (values (color-alpha color)
          (color-red color)
          (color-green color)
          (color-blue color)))

(defun color-intensity (color)
  (multiple-value-bind (r g b)
      (color-rgb color)
    (floor (+ r g b) 3)))

(defun invert-color (color)
  (logior (lognot (logand color #x00ffffff))
          (logand color #xff000000)))

(defun closest-colortable-entry (color table)
  (multiple-value-bind (color-r color-g color-b)
      (color-rgb color)
    (multiple-value-bind (element index score)
        (best-in-array (lambda (c)
                         (multiple-value-bind (r g b)
                             (color-rgb c)
                           (+ (square (- r color-r))
                              (square (- g color-g))
                              (square (- b color-b)))))
                       table
                       :test #'<)
      (declare (ignore element score))
      index)))

(defun make-simple-gray-colormap ()
  (let ((colormap (make-array 256 :element-type '(unsigned-byte 8))))
    (dotimes (i 256)
      (setf (aref colormap i) (make-color i i i)))
    colormap))

(defvar +white+ (make-color #xff #xff #xff))
(defvar +black+ (make-color #x00 #x00 #x00))
(defvar +red+ (make-color #xff #x00 #x00))
(defvar +green+ (make-color #x00 #xff #x00))
(defvar +blue+ (make-color #x00 #x00 #xff))
(defvar +cyan+ (make-color #x00 #xff #xff))
(defvar +magenta+ (make-color #xff #x00 #xff))
(defvar +yellow+ (make-color #xff #xff #x00))