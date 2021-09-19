class Builds::CsvRowValidator
  TITLEIZE = 'titleize'
  NONE = 'none'
  FORMAT_LIST = 'format_list'
  ROW_HEADERS_TO_VIEW_PREP = { # Order of headers matter
    'role' => TITLEIZE, 
    'pvp_or_pve' => TITLEIZE, 
    'weapon1' => TITLEIZE, 
    'weapon2' => TITLEIZE, 
    'build_variant' => TITLEIZE, 
    'role_gist' => NONE, 
    'strengths' => FORMAT_LIST, 
    'weaknesses' => FORMAT_LIST, 
    'hp' => NONE,
    'weapon1_damage' => NONE, 
    'weapon2_damage' => NONE, 
    'physical_armor' => NONE, 
    'elemental_armor' => NONE, 
    'weight_class' => TITLEIZE, 
    'build_link' => NONE,
  }

  ALL_ROLE_VALUES = %w[tank damage healer]
  PVP_OR_PVE_VALUES = %w[pvp pve]
  ALL_WEAPON_VALUES = %w[sword rapier hatchet spear great_axe war_hammer bow musket fire_stalf life_stalf ice_gauntlet]

  @@all_variants = {
    'tank'   => [],
    'damage' => [],
    'healer' => []
  }

  attr_reader :errors

  def initialize(row)
    p @@all_variants
    @row = row
    @errors = []
    @has_zipped_headers_to_data = false
  end

  def valid?
    return false unless check_valid_length_and_zip_headers_to_data

    valid_role? &&
      valid_pvp_or_pve_value? &&
      valid_weapon_values? &&
      valid_build_variant? &&
      has_role_gist? &&
      has_strengths? &&
      has_weaknesses? &&
      hp_is_na? && # HP == 'N/A' always until we know formula for calculating it
      weapons_have_damage? &&
      has_armor_values? &&
      has_weight_class? &&
      has_build_link?
  end

private

  def check_valid_length_and_zip_headers_to_data
    raise RuntimeError.new('Tried to zip headers to data too many times') if @has_zipped_headers_to_data

    if ROW_HEADERS_TO_VIEW_PREP.keys.count != @row.count
      @errors << 'Header length does not match data length'
      return false
    end

    @row = Hash[ROW_HEADERS_TO_VIEW_PREP.keys.zip(@row)]
    @has_zipped_headers_to_data = true # Utilizing side effect of implicit returns for last evaluated value to end up with `true`
  end

  def valid_role?
    if ALL_ROLE_VALUES.include?(@row['role'])
      true
    else
      @errors << 'Invalid role value'
      false
    end
  end

  def valid_pvp_or_pve_value?
    if PVP_OR_PVE_VALUES.include?(@row['pvp_or_pve'])
      true
    else
      @errors << 'Invalid pvp/pve value'
      false
    end
  end

  def valid_weapon_values?
    if ALL_WEAPON_VALUES.include?(@row['weapon1']) && ALL_WEAPON_VALUES.include?(@row['weapon2'])
      true
    else
      @errors << 'Invalid weapon value(s)'
      false
    end
  end

  def valid_build_variant?
    if !@row['build_variant'].present?
      @errors << 'Build variant not present'
      return false 
    end
    
    if !@@all_variants[@row['role']].include?(@row['build_variant'])
      @@all_variants[@row['role']] << @row['build_variant']
      true
    else
      @errors << 'This build variant is already present for the role'
      false 
    end
  end

  def has_role_gist?
    if @row['role_gist'].present?
      true
    else
      @errors << 'Role gist not present'
      false
    end
  end

  def has_strengths?
    if @row['strengths'].is_a?(Array) && @row['strengths'].any?
      true
    else
      @errors << 'Strengths are not present'
      false
    end
  end

  def has_weaknesses?
    if @row['weaknesses'].is_a?(Array) && @row['weaknesses'].any?
      true
    else
      @errors << 'Weaknesses are not present'
      false
    end
  end

  def hp_is_na?
    if @row['hp'] == 'N/A'
      true
    else
      @errors << "HP is not 'N/A'"
      false
    end
  end

  def weapons_have_damage?
    if @row['weapon1_damage'].is_a?(Integer) && @row['weapon2_damage'].is_a?(Integer)
      true
    else
      @errors << 'Weapon damage value(s) not present'
      false
    end
  end

  def has_armor_values?
    if @row['physical_armor'].is_a?(Integer) && @row['elemental_armor'].is_a?(Integer)
      true
    else
      @errors << 'Armor value(s) not present'
      false
    end
  end

  def has_weight_class?
    if @row['weight_class'].present?
      true
    else
      @errors << 'Weight class not present'
      false
    end
  end

  def has_build_link?
    if @row['build_link'].present?
      true
    else
      @errors << 'Build link not present'
      false
    end
  end
end

