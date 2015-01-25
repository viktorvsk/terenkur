ActiveAdmin.register EventType do
  permit_params :name, :permalink, :keywords
  actions :all, except: [:show]

  menu priority: 5, label: proc{ t("active_admin.menu.event_type") }

  index do
    column "Название", :name do |event_type|
      (content_tag(:b, event_type.name) + tag(:br) + content_tag(:i, event_type.event_meta_types.map(&:name).join(', '))).html_safe
    end
    column "Ссылка", :permalink
    actions
  end

  filter :name, label: "Название"
  filter :permalink, label: "Домен"

  form do |f|
    f.inputs "Тип события" do
      f.input :name, label: "Название"
      f.input :permalink, label: "Ссылка"
      f.input :keywords, label: "Ключевые слова для определения типа"
    end

    f.actions
  end

end
