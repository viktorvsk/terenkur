class Conf < RailsSettings::CachedSettings
  def val
    self.value rescue ""
  end

  def val=(v)
    self.value=(v)
  end
end
