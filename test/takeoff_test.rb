# frozen_string_literal: true

require "minitest/autorun"
require_relative "../buildgrid/takeoff"

class TakeoffTest < Minitest::Test
  FakeEntity = Struct.new(:attributes) do
    def set_attribute(dictionary, key, value)
      attributes[[dictionary, key]] = value
    end

    def get_attribute(dictionary, key)
      attributes[[dictionary, key]]
    end
  end

  def test_writes_stable_material_and_role_identity
    entity = FakeEntity.new({})
    record = Buildgrid::Takeoff.write(
      entity,
      material: { "id" => "n25", "name" => "N25 Concrete" },
      role_id: "concrete.slab_from_face.slab_body",
      quantity_m3: 2.4,
      basis: "generated volume",
      takeoff_groups: [
        { "id" => "slabs", "name" => "Slabs" },
        { "id" => "slabs", "name" => "Duplicate name is ignored" }
      ]
    )

    assert_equal "n25", record["material_id"]
    assert_equal "concrete.slab_from_face.slab_body", record["role_id"]
    assert_equal "m3", record["unit"]
    assert_in_delta 2.4, record["quantity"]
    assert_equal 2, record["schema_version"]
    assert_equal [{ "id" => "slabs", "name" => "Slabs" }], record["takeoff_groups"]
  end

  def test_summary_groups_by_material_identity_and_unit
    records = [
      { "material_id" => "n25", "material_name" => "N25", "unit" => "m3", "quantity" => 1.2 },
      { "material_id" => "n25", "material_name" => "N25", "unit" => "m3", "quantity" => 2.3 }
    ]

    summary = Buildgrid::Takeoff.summary(records)

    assert_in_delta 3.5, summary.fetch(["n25", "N25", "m3"])
  end

  def test_summary_rows_are_sorted_for_display
    rows = Buildgrid::Takeoff.summary_rows([
      { "material_id" => "b", "material_name" => "N32", "unit" => "m3", "quantity" => 1.0 },
      { "material_id" => "a", "material_name" => "N25", "unit" => "m3", "quantity" => 2.0 }
    ])

    assert_equal ["N25", "N32"], rows.map { |row| row["material_name"] }
  end

  def test_csv_export_uses_grouped_rows
    csv = Buildgrid::Takeoff.to_csv([
      { "material_id" => "n25", "material_name" => "N25, Concrete", "unit" => "m3", "quantity" => 3.5 }
    ])

    assert_includes csv, "Material,Material ID,Quantity,Unit"
    assert_includes csv, '"N25, Concrete",n25,3.500,m3'
  end

  def test_grouped_rows_count_an_item_once_in_each_selected_group
    records = [
      {
        "material_id" => "n25", "material_name" => "N25", "unit" => "m3", "quantity" => 2.0,
        "takeoff_groups" => [
          { "id" => "concrete", "name" => "Concrete" },
          { "id" => "slabs", "name" => "Slabs" }
        ]
      },
      {
        "material_id" => "n25", "material_name" => "N25", "unit" => "m3", "quantity" => 1.0,
        "takeoff_groups" => [{ "id" => "slabs", "name" => "Slabs" }]
      }
    ]

    rows = Buildgrid::Takeoff.grouped_rows(records)

    assert_in_delta 2.0, rows.find { |row| row["group_id"] == "concrete" }["quantity"]
    assert_in_delta 3.0, rows.find { |row| row["group_id"] == "slabs" }["quantity"]
    assert_in_delta 3.0, Buildgrid::Takeoff.summary_rows(records).first["quantity"]
  end

  def test_grouped_csv_includes_unassigned_legacy_records
    csv = Buildgrid::Takeoff.grouped_csv([
      { "material_id" => "n25", "material_name" => "N25", "unit" => "m3", "quantity" => 1.0 }
    ])

    assert_includes csv, "Takeoff Group,Group ID,Material"
    assert_includes csv, 'Unassigned,"",N25,n25,1.000,m3'
  end

end
