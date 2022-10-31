# frozen_string_literal: true

ActiveAdmin.register_page "Tools" do
  menu label: "⚙️ Outils", priority: 10

  content do
    render partial: "tools"
  end
end
