module Instabil
  WEEKDAYS = %w(Montag Dienstag Mittwoch Donnerstag Freitag)

  def self.frozen?
    ENV["FROZEN"] == "true" || locked?
  end
  
  def self.locked?
    ENV["LOCKED"] == "true"
  end
  
  SUBJECT_MAP = {
    "d" => "Deutsch",
    "m" => "Mathe",
    
    "e" => "Englisch",
    "f" => "Französisch",
    "fb" => "Französisch (bili)",
    "sp" => "Spanisch",
    
    "ph" => "Physik",
    "ch" => "Chemie",
    "bio" => "Biologie",
    
    "wi" => "Wirtschaft",
    
    "g" => "Geschichte",
    "gb" => "Geschichte (bili)",
    "gk" => "Gk",
    "gkb" => "Gk (bili)",
    "geogr" => "Erdkunde",
    "geogrb" => "Erdkunde (bili)",
    "geol" => "Geologie",
    
    "s" => "Sport",
    "inf" => "Informatik",
    "mu" => "Musik",
    "bk" => "Kunst",
    "phi" => "Philosophie",
    "psy" => "Psychologie",
    
    "rel" => "Religion",
    "sf" => "Seminarkurs",
    "eth" => "Ethik",
    
    "lut" => "L&T"
  }
end