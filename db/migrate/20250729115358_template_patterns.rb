class TemplatePatterns < ActiveRecord::Migration[8.0]
  def change
    add_column :components, :template_patterns, :text, default: '{{}}'
  end
end
