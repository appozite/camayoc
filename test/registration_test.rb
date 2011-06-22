class RegistrationTest < Test::Unit::TestCase
  
  def test_accessing_stats_creates_it
    stats = Camayoc["foo:bar"]
    assert_equal(Camayoc::Stats,stats.class)
  end

  def test_accessing_stats_returns_same_instance
    stats1 = Camayoc["foo:bar"]
    stats2 = Camayoc["foo:bar"]
    assert_same(stats1,stats2)
  end

  def test_accessing_path_with_no_ancestor_leaves_parent_nil
    stats1 = Camayoc["foo:bar"]
    assert_nil(stats1.parent)
  end

  def test_accessing_path_with_already_existing_ancestor_sets_parent
    parent = Camayoc["foo"]
    child = Camayoc["foo:bar"]
    assert_same(parent,child.parent)
  end
  
  def test_accessing_path_with_intermediate_steps_gets_closest_existing_ancestor_as_parent
    parent = Camayoc["foo"]
    child = Camayoc["foo:a:b:c:baz"]
    assert_same(parent,child.parent)
  end

  def test_accessing_path_in_middle_of_existing_hierarchy_reassociates_children
    root = Camayoc["foo"]
    child1 = Camayoc["foo:a:b:c:1"]
    child2 = Camayoc["foo:a:b:c:2"]
    middle = Camayoc["foo:a:b"]
    
    assert_same(root,middle.parent)
    assert_same(middle,child1.parent)
    assert_same(middle,child2.parent)
  end
  
  def test_all_lists_all_existing_instances
    root = Camayoc["foo"]
    child1 = Camayoc["foo:a:b:c:1"]
    child2 = Camayoc["foo:a:b:c:2"]
    middle = Camayoc["foo:a:b"]
    
    all = Camayoc.all
    all = all.sort_by{|stats| stats.name}

    assert_equal([root,middle,child1,child2],all)
  end

  def test_brackets_on_stats_gets_namespaced_descendant
    parent = Camayoc["foo:bar"]
    desc = parent["a:b:c"]
    assert_equal(Camayoc.join(parent.name,"a:b:c"),desc.name)
    assert_equal(parent,desc.parent)
  end

  def test_join_builds_name_with_delimiter
    assert_equal("a:b:c",Camayoc.join("a","b","c"))
    assert_equal("foo:bar:baz",Camayoc.join(%w(foo bar:baz)))
  end

  def teardown
    Camayoc.instance_variable_get("@registry").clear
  end
end