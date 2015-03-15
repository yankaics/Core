PaperTrail::Version.module_eval do
  self.abstract_class = true
  self.table_name = :data_api_versions
end
