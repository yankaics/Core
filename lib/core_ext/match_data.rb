class MatchData
  def to_hash
    Hash[ (self.names.map { |n| n.to_sym }).zip( self.captures ) ]
  end
end
