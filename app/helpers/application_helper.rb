module ApplicationHelper

  def display_popup_body(html)
    if html =~ /\{\{register\}\}/
      form = render( partial: 'users/register_user_form', locals: { user: User.new} )
      html.gsub!('{{register}}', form)
    end
    html.html_safe
  end

  def lazy_image_tag(source, options={})
    if options[:class].present?
      options[:class] << ' lazy'
    else
      options[:class] = 'lazy'
    end
    options['data-original'] = source
    image_tag('/spinner.gif', options)
  end
end
