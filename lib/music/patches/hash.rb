class Hash
  def flip
    Hash[*self.to_a.collect(&:reverse).flatten]
  end
end
