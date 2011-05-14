module Sugar
  module ActionView
    module Structure
      VIEW_PLACEHOLDERS = {
        'create' => 'new',
        'update' => 'edit'
      }

      def view_name
        action_name = controller.action_name
        VIEW_PLACEHOLDERS[action_name] || action_name
      end

      def default_page_title
        text = case action_name
               when 'index'
                 controller_name.camelize
               when 'new', 'create'
               "#{t('krasivotokak.sugar.new', :default => 'New')} #{controller_name.classify.constantize.human_name}"
               when 'edit', 'update'
               "#{t('krasivotokak.sugar.edit', :default => 'Editing')} #{controller_name.classify.constantize.human_name}"
               else
                 t("#{controller_name}.#{view_name}.title")
               end
      %(<span class="trasnlation_missing">#{text}</span>)
      end

      # Return page title for use in layout
      def page_title(title = nil)
        @page_title = if title
                        title
                      else
                        @page_title || t("#{controller_name}.#{view_name}.title", :default => Rails.env.production? ? default_page_title : nil)
                      end
      end

      def head_title(default = false, separator = ' | ')
        default ||= t('application.meta.title')
        strip_tags([page_title, default].compact.join(separator))
      end

      # Build simple navigation list
      def navigation_list(menu)
        returning '' do |result|
          menu.each do |item|
            path = "/#{item}"
            uri = request.request_uri
            title = t("#{item}.index.title", :default => item.to_s.camelize)
            result << content_tag(:li, :class => uri.starts_with?(path) ? 'selected' : nil) do
              link_to_unless_current(title, path) {
                content_tag(:strong, title)
              }
            end
          end
        end
      end

    end
  end
end
