module ApplicationHelper
  def markdown(text)
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    @markdown.render(text).html_safe if text
  end
end
