require "sitepress-core"

module Sitepress
  autoload :CLI,              "sitepress/cli"
  autoload :Compiler,         "sitepress/compiler"
  autoload :PreviewServer,    "sitepress/preview_server"
  autoload :Project,          "sitepress/project"
  autoload :ProjectTemplate,  "sitepress/project_template"
  autoload :REPL,             "sitepress/repl"
end
