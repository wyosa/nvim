;extends

              ((comment) @comment
                .
                [
                  (short_var_declaration
                    right: (expression_list (raw_string_literal) @injection.content))
                  (assignment_statement
                    right: (expression_list (raw_string_literal) @injection.content))
                  (var_declaration
                    (var_spec
                      value: (expression_list (raw_string_literal) @injection.content)))
                  (call_expression
                    arguments: (argument_list (raw_string_literal) @injection.content))
                ]
                (#match? @comment "^//\\s*sql\\s*$|^/\\*\\s*sql\\s*\\*/$")
                (#set! injection.language "sql"))
            
              ((comment) @comment
                .
                [
                  (short_var_declaration
                    right: (expression_list (raw_string_literal) @injection.content))
                  (assignment_statement
                    right: (expression_list (raw_string_literal) @injection.content))
                  (var_declaration
                    (var_spec
                      value: (expression_list (raw_string_literal) @injection.content)))
                  (call_expression
                    arguments: (argument_list (raw_string_literal) @injection.content))
                ]
                (#match? @comment "^//\\s*postgresql\\s*$|^/\\*\\s*postgresql\\s*\\*/$")
                (#set! injection.language "postgresql"))
            
              ((comment) @comment
                .
                [
                  (short_var_declaration
                    right: (expression_list (raw_string_literal) @injection.content))
                  (assignment_statement
                    right: (expression_list (raw_string_literal) @injection.content))
                  (var_declaration
                    (var_spec
                      value: (expression_list (raw_string_literal) @injection.content)))
                  (call_expression
                    arguments: (argument_list (raw_string_literal) @injection.content))
                ]
                (#match? @comment "^//\\s*clickhouse\\s*$|^/\\*\\s*clickhouse\\s*\\*/$")
                (#set! injection.language "clickhouse"))
            
              ((raw_string_literal) @injection.content
                (#match? @injection.content "^\\_s*\\c\\(select\\|insert\\|update\\|delete\\|with\\|create\\|alter\\|drop\\|truncate\\|merge\\)\\>")
                (#set! injection.language "sql"))
            