view: inventory_items {
  label: "Items in Inventory"
  sql_table_name: inventory_items ;;
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.cost ;;
  }

  dimension_group: created {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.created_at ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.sold_at ;;
  }

  dimension: is_sold {
    type: yesno
    sql: ${sold_raw} is not null ;;
  }

  dimension: days_in_inventory {
    description: "days between created and sold date"
    type: number
    sql: DATEDIFF('day', ${created_raw}, coalesce(${sold_raw},CURRENT_DATE)) ;;
  }

  dimension: days_in_inventory_tier {
    type: tier
    sql: ${days_in_inventory} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: days_since_arrival {
    description: "days since created - useful when filtering on sold yesno for items still in inventory"
    type: number
    sql: DATEDIFF('day', ${created_date}, GETDATE()) ;;
  }

  dimension: days_since_arrival_tier {
    type: tier
    sql: ${days_since_arrival} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: product_distribution_center_id {
    hidden: yes
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  measure: sold_count {
    type: count
    drill_fields: [detail*]
    filters:  {
      field: is_sold
      value: "Yes"
    }

  }

  measure: sold_percent {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${sold_count}/NULLIF(${count},0) ;;
  }

  measure: total_cost {
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: average_cost {
    type: average
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: number_on_hand {
    type: number
    sql: ${count} - ${sold_count} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
  }

}
