(require 'ox-md)

;; Define a custom backend that extends the markdown backend
(org-export-define-derived-backend 'custom-md 'md
  :translate-alist
  '((src-block . org-custom-md-src-block)
    (drawer . org-custom-md-drawer)))

;; Custom function to handle source blocks
(defun org-custom-md-src-block (src-block contents info)
  "Transcode a SRC-BLOCK element from Org to Markdown with triple backticks."
  (let* ((lang (org-element-property :language src-block))
         (code (org-remove-indentation
                (org-element-property :value src-block)))
         (lang-str (if lang (concat lang "\n") "\n")))
    (format "```%s%s```" lang-str code)))

;; Custom function to handle drawers
(defun org-custom-md-drawer (drawer contents info)
  "Transcode a DRAWER element from Org to details block format."
  (let* ((name (org-element-property :drawer-name drawer))
         (contents (or contents ""))
         (title (capitalize name)))
    (format "{{< details title=\"%s. Click on it to reveal it.\" closed=\"true\" >}}\n%s{{< /details >}}"
            title contents)))

;; Function to export current buffer
(defun org-export-to-custom-md-buffer ()
  "Export current Org buffer to Markdown with custom formatting."
  (interactive)
  (org-export-to-buffer 'custom-md "*Org Custom MD Export*"))

;; Function to export to file
(defun org-export-to-custom-md-file (&optional async subtreep visible-only)
  "Export current Org buffer to a Markdown file with custom formatting."
  (interactive)
  (let* ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'custom-md outfile async subtreep visible-only)))
