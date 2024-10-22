; https://github.com/nvim-treesitter/nvim-treesitter/blob/bab7b0f20bd3e805b77231a77f516c7d69382693/queries/ecma/injections.scm#L9
(call_expression
  function: [
    (non_null_expression
     (await_expression
       (instantiation_expression
         (identifier) @_name)))
    (non_null_expression
      (instantiation_expression
        (identifier) @_name))

    ; slonik sql.type(...)
    (call_expression
      function: (member_expression
                  object: (identifier) @_name
                  property: (property_identifier) @_prop
                  (#any-of? @_prop "type" "typeAlias")))
  ]
  (#eq? @_name "sql")
  arguments: [
    (arguments
      (template_string) @injection.content)
    (template_string) @injection.content
  ]
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql"))

(binary_expression
  left: [
    (binary_expression
      left: [
        ((await_expression (identifier) @_name))
        (identifier) @_name
      ])
  ]
  (#eq? @_name "sql")
  right: (template_string) @injection.content
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "sql"))

