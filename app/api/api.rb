require 'grape-swagger'

class API < Grape::API
  include APIGuard

  content_type :json, 'application/vnd.api+json'
  content_type :json, 'application/json'
  content_type :xml, 'text/xml'

  default_format :json

  formatter :json, Grape::Formatter::Rabl
  formatter :xml, Grape::Formatter::Rabl

  before do
    @request_path = "#{@namespace}#{params.path}"
  end

  mount API::V1

  get "/" do
    request_url = URI.parse(request.url)
    request_path_extname = request_url.path[/\..+$/]
    request_path = request_url.path.gsub(/\..+$/, '')
    request_url.path = request_path
    redirect "#{request_url}docs.html", permanent: true if request_path_extname != '.json'
    { documentation_url: "#{request_url}docs.json" }
  end

  include APIDocsExtended

  documentation_settings = {
    base_path: ->(req) { req.host.match(/^api\./) ? '/' : '/api' },
    api_version: 'v1',
    mount_path: '/docs',
    root_base_path: true,
    # markdown: GrapeSwagger::Markdown::RedcarpetAdapter.new(render_options: { highlighter: :rouge }),
    info: {
      title: "Core API",
      description: "本系統提供 OAuth 2.0 認證協定以及相關使用者資源 API 供開發者存取，可用於各平台應用程式之開發，並提供服務予使用者。"
    }
  }

  add_swagger_documentation(documentation_settings)

  mount API::Open
end
