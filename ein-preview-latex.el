(eval-when-compile
  (require 'cl))

(require 'latex-math-preview)

(defun ein-preview-latex-everywhere ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (loop for p = (re-search-forward "\\(\\$[^$]+\\$\\|\\$\\$[^$]+\\$\\$\\)" nil t)
          while p
          if (equal (ein:cell-language (ein:worksheet-get-current-cell :pos (point))) "markdown")
          do (save-excursion
               (re-search-backward "[^$]")
               (ein-preview-latex-at-point)))))

(defun ein-preview-latex-at-point ()
  (interactive)
  (ein-preview-latex-set-local-options)
  (destructuring-bind (start . end) (bounds-of-thing-at-point 'latex-math)
    (let* ((str (buffer-substring-no-properties start end))
           (dot-tex (latex-math-preview-make-temporary-tex-file str latex-math-preview-latex-template-header))
           (png (latex-math-preview-make-png-file dot-tex)))
      (put-text-property start end 'display (create-image png)))))

(defun ein-preview-latex-disable-at-point ()
  (interactive)
  (save-excursion
    (search-forward "$")
    (destructuring-bind (start . end) (bounds-of-thing-at-point 'latex-math)
      (remove-text-properties start end '(display)))))

(defun ein-preview-latex-set-local-options ()
  (setq-local latex-math-preview-dvipng-color-option nil)
  (setq-local latex-math-preview-image-background-color (face-attribute 'ein:cell-input-area :background))
  (setq-local latex-math-preview-command-option-alist
              '((pdflatex-to-pdf "-output-format" "pdf") (pdflatex-to-dvi "-output-format" "dvi")
                (dvipng "-x" "1400") (dvips-to-ps "-Ppdf") (dvips-to-eps "-Ppdf")
                (gs-to-png
                 "-dSAFER" "-dNOPAUSE" "-sDEVICE=png16m" "-dTextAlphaBits=4" "-dBATCH" "-dGraphicsAlphaBits=4" "-dQUIET")
                (gswin32c-to-png
                 "-dSAFER" "-dNOPAUSE" "-sDEVICE=png16m" "-dTextAlphaBits=4" "-dBATCH" "-dGraphicsAlphaBits=4" "-dQUIET"))))
