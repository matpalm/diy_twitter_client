
class String
  
  def duplicate_whitespace_removed
    gsub(/\s+/, ' ').gsub(/\n/,' ').gsub(/\s+/,' ')
  end

end
