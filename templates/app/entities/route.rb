class Route < Draco::Entity
  component Match
  component Response

  def uri
    parts = []
    parts << parent.uri if parent
    parts << match.uri
    parts.join
  end
end
