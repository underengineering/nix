local function get_snippets()
    local ls = require("luasnip")
    local s = ls.snippet
    local sn = ls.snippet_node
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node
    local d = ls.dynamic_node
    local r = ls.restore_node
    local l = require("luasnip.extras").lambda
    local rep = require("luasnip.extras").rep
    local p = require("luasnip.extras").partial
    local m = require("luasnip.extras").match
    local n = require("luasnip.extras").nonempty
    local dl = require("luasnip.extras").dynamic_lambda
    local fmt = require("luasnip.extras.fmt").fmt
    local fmta = require("luasnip.extras.fmt").fmta
    local types = require("luasnip.util.types")
    local conds = require("luasnip.extras.conditions")
    local conds_expand = require("luasnip.extras.conditions.expand")

    return {
        s("flake", fmt([[
           {{
              inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
              inputs.flake-utils.url = "github:numtide/flake-utils";
              outputs = {{
                self,
                nixpkgs,
                flake-utils,
              }}:
                flake-utils.lib.eachDefaultSystem (system: let
                  pkgs = nixpkgs.legacyPackages.${{system}};
                in {{
                  devShell = pkgs.mkShell {{
                    nativeBuildInputs = [];
                    buildInputs = [];
                  }};
                }});
            }}
        ]], {})),
        s("tormsc", fmt([[
            import {{ Column, Entity }} from "typeorm";

            @Entity()
            export class {entity_name} {{
                @Column()
                {field_name}: {field_type};
            }}
        ]], {
            entity_name = i(1, "entityName"),
            field_name = i(2, "fieldName"),
            field_type = i(3, "fieldType"),
        }))
    }
end

return function()
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip").add_snippets("all", get_snippets())
end
