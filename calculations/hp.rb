#################### WIP: not complete until calculation for armor is figured out (because of the perk which scales hp off physical armor) ####################
class Calculations::HP
  PLAYER_STARTING_HEALTH = 778
  MAX_HEALTH_CON_PERK_NUM = 100
  CON_RANGES = {
    001..100 => 25,
    101..200 => 24,
    201..300 => 23,
    301..400 => 22,
    401..500 => 21
  }

  def initialize(attr_data:{}, armor_data:{})
    @total_con = attr_data['constitution']
    @armor_data = armor_data
  end

  def evaluate
    hp_from_con = multiplay_points_spent_in_con_and_add_them_together(produce_ranges_to_points_spent)
    PLAYER_STARTING_HEALTH + hp_from_con # + 10% of physical armor
  end

private

  def produce_ranges_to_points_spent
    result = {}

    return result if @total_con == 5

    range_arr = CON_RANGES.keys
    range_arr.each_with_index do |range, idx|
      if @total_con >= range.last
        result[range] = range.count
      elsif range.cover?(@total_con)
        result[range] = idx == 0 ? @total_con : @total_con % range_arr[idx - 1].last
      end
    end

    result[range_arr.first] -= 5 if result[range_arr.first] # Players start with 5 attribute points in each category, and they don't apply towards anything

    result
  end

  def multiplay_points_spent_in_con_and_add_them_together(ranges_to_points_spent)
    health_points_sum = 0

    ranges_to_points_spent.each do |range, points_spent|
      health_points_sum += CON_RANGES[range] * points_spent
    end

    health_points_sum
  end

  def has_max_health_perk?
    @total_con >= MAX_HEALTH_CON_PERK_NUM
  end
end