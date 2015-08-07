ActiveAdmin.register ServiceNavigation do
  menu priority: 70, label: "服務導覽選單", if: proc { current_admin.root? }

  scope_to(if: proc { current_admin.scoped? }) { current_admin }

  permit_params do
    permitted = [:name, :url, :color, :icon, :background_image, :background_pattern, :description, :introduction, :order, :visible, :opened, :show_on_index, :show_on_mobile_index, :index_order, :index_size]
    permitted
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :name
      f.input :url
      f.input :color
      f.input :icon, hint: f.object.icon.present? \
        ? image_tag(f.object.icon.url) \
        : '請選擇圖片上傳'
      f.input :background_image, hint: f.object.background_image.present? \
        ? image_tag(f.object.background_image.url) \
        : '請選擇圖片上傳'
      f.input :background_pattern, hint: f.object.background_pattern.present? \
        ? image_tag(f.object.background_pattern.url) \
        : '請選擇圖片上傳'
      f.input :description
      f.input :introduction
      f.input :order
      f.input :visible
      f.input :opened
      f.input :show_on_index
      f.input :show_on_mobile_index
      f.input :index_order
      f.input :index_size
    end

    f.actions
  end
end
