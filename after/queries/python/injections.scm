;extends
; Extend the standard Tree-sitter queries with embedded language highlighting.

; Highlight SQL using a marker at the start of the string.
((string_content) @injection.content
  (#match? @injection.content "^(\r\n|\r|\n)*-{2,}( )*[sS][qQ][lL]")
  (#set! injection.language "sql"))

; Highlight JavaScript using a marker at the start of the string.
((string_content) @injection.content
  (#match? @injection.content "^(\r\n|\r|\n)*/{2,}( )*[jJ][aA][vV][aA][sS][cC][rR][iI][pP][tT]")
  (#set! injection.language "javascript"))

; Highlight TypeScript using a marker at the start of the string.
((string_content) @injection.content
  (#match? @injection.content "^(\r\n|\r|\n)//+( )*[tT][yY][pP][eE][sS][cC][rR][iI][pP][tT]")
  (#set! injection.language "typescript"))

; Highlight HTML using a marker at the start of the string.
((string_content) @injection.content
  (#match? @injection.content "^(\r\n|\r|\n)\\<\\!-{2,}( )*[hH][tT][mM][lL]( )*-{2,}\\>")
  (#set! injection.language "html"))

; Highlight CSS using a marker at the start of the string.
((string_content) @injection.content
  (#match? @injection.content "^(\r\n|\r|\n)/\\*+( )*[cC][sS][sS]( )*\\*+/")
  (#set! injection.language "css"))

; Highlight Python using a marker at the start of the string.
((string_content) @injection.content
  (#match? @injection.content "^(\r\n|\r|\n)*#+( )*[pP][yY][tT][hH][oO][nN]")
  (#set! injection.language "python"))

; Highlight SQL using the comment before the string.
((comment) @comment .
  (expression_statement
    (assignment right:
      (string
        (string_content)
        @injection.content
        (#match? @comment "^#+( )*[sS][qQ][lL]( )*")
        (#set! injection.language "sql")))))

; Highlight JavaScript using the comment before the string.
((comment) @comment .
  (expression_statement
    (assignment right:
      (string
        (string_content)
        @injection.content
        (#match? @comment "^#+( )*[jJ][aA][vV][aA][sS][cC][rR][iI][pP][tT]( )*")
        (#set! injection.language "javascript")))))

; Highlight TypeScript using the comment before the string.
((comment) @comment .
  (expression_statement
    (assignment right:
      (string
        (string_content)
        @injection.content
        (#match? @comment "^#+( )*[tT][yY][pP][eE][sS][cC][rR][iI][pP][tT]( )*")
        (#set! injection.language "typescript")))))

; Highlight HTML using the comment before the string.
((comment) @comment .
  (expression_statement
    (assignment right:
      (string
        (string_content)
        @injection.content
        (#match? @comment "^#+( )*[hH][tT][mM][lL]( )*")
        (#set! injection.language "html")))))

; Highlight CSS using the comment before the string.
((comment) @comment .
  (expression_statement
    (assignment right:
      (string
        (string_content)
        @injection.content
        (#match? @comment "^#+( )*[cC][sS][sS]( )*")
        (#set! injection.language "css")))))

; Highlight Python using the comment before the string.
((comment) @comment .
  (expression_statement
    (assignment right:
      (string
        (string_content)
        @injection.content
        (#match? @comment "^#+( )*[pP][yY][tT][hH][oO][nN]( )*")
        (#set! injection.language "python")))))
