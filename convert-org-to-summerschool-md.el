;; generated with Anthropic Claude Sonnet 4 and a few trial and errors
;; Usage instructions as comments:
;;
;; 1. Evaluate this code in your Emacs (you can use C-x C-e)
;; 2. Open your .org file
;; 3. Run: M-x org-export-to-custom-md-buffer (to see preview)
;; 4. Or run: M-x org-export-to-custom-md-file (to save to file)
;;

(require 'ox-md)



;; Define a custom backend that extends the markdown backend
(org-export-define-derived-backend 'custom-md 'md
  :translate-alist
  '((src-block . org-custom-md-src-block)
    (drawer . org-custom-md-drawer)
    (headline . org-custom-md-headline)
    (template . org-custom-md-template)))

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

;; Custom function to handle headlines (shift all headers down by one level)
(defun org-custom-md-headline (headline contents info)
  "Transcode a HEADLINE element from Org to Markdown, shifting level down by 1."
  (let* ((level (+ (org-element-property :level headline) 1))  ; Add 1 to shift down
         (title (org-export-data (org-element-property :title headline) info))
         (tags (and (plist-get info :with-tags)
                   (org-export-get-tags headline info)))
         (tags-str (and tags
                       (format " %s" (mapconcat (lambda (tag) (format ":%s:" tag)) tags "")))))
    (concat
     (make-string level ?#) " " title (or tags-str "") "\n\n"
     (or contents ""))))

;; Custom template function to handle title and author
(defun org-custom-md-template (contents info)
  "Return complete document string after Org->Markdown conversion with custom title/author."
  (let* ((title (org-export-data (plist-get info :title) info))
         (author (org-export-data (plist-get info :author) info))
         (header-section ""))

    ;; Build header section
    (when (org-string-nw-p title)
      (setq header-section (concat header-section "# " title "\n\n")))

    (when (org-string-nw-p author)
      (setq header-section (concat header-section author "\n\n")))

    ;; Combine header with content
    (concat header-section contents)))

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

;; Main function that combines both custom backend and post-processing
(defun org-export-to-custom-md-file ()
  "Export using custom backend and post-process for drawer conversion."
  (interactive)
  (let ((md-buffer (org-export-to-buffer 'custom-md "*Org Custom MD Export*")))
    (with-current-buffer md-buffer
      ;; Post-process to handle custom drawer format that wasn't caught by backend
      (goto-char (point-min))

      ;; Convert custom drawers (:Name: content :Name-end:)
      (while (re-search-forward "^:\\([^:]+\\):\\s-*\n\\(\\(?:.*\n\\)*?\\)^:\\1-end:\\s-*$" nil t)
        (let* ((drawer-name (match-string 1))
               (drawer-content (match-string 2))
               (title (capitalize drawer-name)))
          (replace-match
           (format "{{< details title=\"%s. Click on it to reveal it.\" closed=\"true\" >}}\n%s{{< /details >}}"
                   title (string-trim drawer-content)))))

      (switch-to-buffer md-buffer))))
