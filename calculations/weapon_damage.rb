class Calculations::WeaponDamage
  WEAPONS_TO_ATTRIBUTES = { # Order of the attribute types matters. First attribute is primary, second is secondary
    'war_hammer'    => %w[strength],
    'great_axe'     => %w[strength],
    'bow'           => %w[dexterity],
    'ice_gauntlet'  => %w[intelligence],
    'fire_staff'    => %w[intelligence],
    'life_staff'    => %w[focus],
    'sword'         => %w[strength dexterity],
    'rapier'        => %w[dexterity intelligence],
    'hatchet'       => %w[strength dexterity],
    'spear'         => %w[dexterity strength],
    'musket'        => %w[dexterity intelligence]
  }
  ATTRIBUTE_RANGES = {
    only: {
      001..100 => 0.01625,
      101..150 => 0.013,
      151..200 => 0.0117,
      201..250 => 0.0104,
      251..300 => 0.0091,
      300..600 => 0.0078
    },
    primary: {
      001..100 => 0.01463,
      101..150 => 0.01170,
      151..200 => 0.01053,
      201..250 => 0.00936,
      251..300 => 0.00819,
      300..600 => 0.00720
    },
    secondary: {
      001..100 => 0.010563,
      101..150 => 0.00845,
      151..200 => 0.00761,
      201..250 => 0.00676,
      251..300 => 0.00592,
      300..600 => 0.00507
    }
  }

  def initialize(weapon_data:, attr_data:, lvl:60)
    @weapon_data = weapon_data
    @attr_data = attr_data
    @lvl = lvl
  end

  def evaluate
    @weapon_data['base_damage'] * (level_percentage + attribute_percentage)
  end

private

  def level_percentage
    subtraction_amount = @lvl == 1 ? 0 : 1 
    1 + 0.025 * (@lvl - subtraction_amount)
  end

  def attribute_percentage
    raise ArgumentError.new('You must provide a weapon type from the available list of known weapons') unless WEAPONS_TO_ATTRIBUTES[@weapon_data['type']]

    case WEAPONS_TO_ATTRIBUTES[@weapon_data['type']].count
    when 1
      ranges_to_points_spent = produce_ranges_to_points_spent(WEAPONS_TO_ATTRIBUTES[@weapon_data['type']].first)
      multiplay_points_spent_in_attributes_and_add_them_together(ranges_to_points_spent)
    when 2
      ranges_to_points_spent1 = produce_ranges_to_points_spent(WEAPONS_TO_ATTRIBUTES[@weapon_data['type']].first, :primary)
      ranges_to_points_spent2 = produce_ranges_to_points_spent(WEAPONS_TO_ATTRIBUTES[@weapon_data['type']].first, :secondary)

      multiplay_points_spent_in_attributes_and_add_them_together(ranges_to_points_spent1, :primary) +
        multiplay_points_spent_in_attributes_and_add_them_together(ranges_to_points_spent2, :secondary)
    end
  end

  def produce_ranges_to_points_spent(attr_type, attr_significance=:only)
    points_in_attr_type = @attr_data[attr_type]
    result = {}

    return result if points_in_attr_type == 5

    ranges_to_percentages = ATTRIBUTE_RANGES[attr_significance]
    range_arr = ranges_to_percentages.keys
    range_arr.each_with_index do |range, idx|
      if points_in_attr_type >= range.last
        result[range] = range.count 
      elsif range.cover?(points_in_attr_type)
        result[range] = idx == 0 ? points_in_attr_type : points_in_attr_type % range_arr[idx - 1].last
      end
    end

    result[range_arr.first] -= 5 if result[range_arr.first] # Players start with 5 attribute points in each category, and they don't apply towards anything

    result
  end

  def multiplay_points_spent_in_attributes_and_add_them_together(ranges_to_points_spent, attr_significance=:only)
    attr_points_sum = 0

    ranges_to_points_spent.each do |range, points_spent|
      attr_points_sum += ATTRIBUTE_RANGES[attr_significance][range] * points_spent
    end

    attr_points_sum
  end
end