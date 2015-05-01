module ApplicationHelper
  def markdown(text)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    @markdown.render(text).html_safe if text
  end

  def about_url
    ENV['APP_ABOUT_URL']
  end

  def contact_url
    ENV['APP_CONTACT_URL']
  end
end
