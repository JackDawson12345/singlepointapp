class UpdateComponentsForCustomization < ActiveRecord::Migration[8.0]
  def change
    # Update the template_patterns column to have a better default
    change_column_default :components, :template_patterns, from: "{{}}", to: "{}"

    # Add a field_types column to specify the type of each editable field
    add_column :components, :field_types, :text, default: "{}"

    # Add example usage comments
    # field_types example: {"title": "text", "image_url": "image", "background_color": "color"}
    # editable_fields example: "title,image_url,background_color"
    # template_patterns example: {"title": "{{title}}", "image": "<img src='{{image_url}}' />"}
  end
end