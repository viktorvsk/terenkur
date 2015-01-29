module ApplicationHelper

  def display_popup_body(html)
    if html =~ /\{\{register\}\}/
      form = render( partial: 'users/register_user_form', locals: { user: User.new} )
      html.gsub!('{{register}}', form)
    end
    html.html_safe
  end

end
