class DataAPIVersion < PaperTrail::Version
  self.table_name = :data_api_versions
  self.sequence_name = :data_api_versions_id_seq
end
