ActiveAdmin.register Conf do
  permit_params :var, :val, :v
  actions :all, except: [:show]
  menu priority: 10, label: proc{ t("active_admin.menu.conf") }
  index do
    column "Название", :var do |conf|
      t("conf.#{conf.var}")
    end
    column "Значение", :value
    actions
  end

  form do |f|
    f.inputs t("conf.#{f.object.var}") do
      f.input :var
      if f.object.var.in?(%w{popup.body welcome.message})
        f.cktext_area :val, :ckeditor => {:toolbar => 'mini', language: 'ru'}
      elsif f.object.var.in?(%w{robots})
        f.input :val, as: :text
      else
        f.input :val, as: :text
      end
    end
    f.actions
  end
end