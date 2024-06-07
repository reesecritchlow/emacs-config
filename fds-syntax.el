;; Define a new major mode for FDS-Inputfile
(define-generic-mode 'fds-mode
  ;; Comments
  '("!")
  ;; Keywords
  '(;; "CELL_CENTERED" "MATL_ID" "PART_ID" "PROP_ID" "QUANTITY" "SPEC_ID" "TEMPORAL_STATISTIC"
    ;; "OTHER_FILES" "CLIP_DT_RESTRICTIONS_MAX" "MAXIMUM_DENSITY" "MAXIMUM_TEMPERATURE"
    ;; Add the rest of the keywords from the XML
    )
  ;; Font lock settings (highlighting)
  '(("\\b[0-9]+\\b" . font-lock-constant-face) ;; Numbers in red
    ("\\b\\(CELL_CENTERED\\|MATL_ID\\|PART_ID\\|PROP_ID\\|QUANTITY\\|SPEC_ID\\|TEMPORAL_STATISTIC\\|OTHER_FILES\\|CLIP_DT_RESTRICTIONS_MAX\\|MAXIMUM_DENSITY\\|MAXIMUM_TEMPERATURE\\)\\b" . font-lock-keyword-face) ;; Keywords in blue
    ("\"[^\"]*\"" . font-lock-string-face) ;; Strings in double quotes
    ("'[^']*'" . font-lock-string-face)  ;; Strings in single quotes
    ("&\\w+" . font-lock-preprocessor-face) ;; Ampersand-prefixed keywords
    ("\\b\\(\\w+\\(?:_\\w+\\)*\\)\\s-*=" 1 font-lock-variable-name-face) ;; Left side of assignment
    ;; Add more rules as needed
    )
  ;; File extensions that trigger this mode
  '("\\.fds\\'")
  ;; Additional setup code
  nil
  ;; Description
  "A major mode for editing FDS-Inputfile files.")
