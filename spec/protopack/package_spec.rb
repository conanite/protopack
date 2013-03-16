# -*- coding: utf-8 -*-

require File.expand_path('../../spec_helper', __FILE__)

describe Protopack::Package do

  before {
    Protopack::Package.config_root = File.expand_path('../packages', __FILE__)
    Widget.destroy_all
  }

  it "should find all the packages" do
    Protopack::Package.all.map(&:name).join(" ").should == "advanced-widgets standard-widgets"
  end

  it "should find a given package" do
    p = Protopack::Package.find("standard-widgets")
    p.name.should == "standard-widgets"

    p.title.en.should == "Standard Widgets"
    p.title.fr.should == "Widgets standards"

    p.description.en.should == "Use these widgets for everyday widgeting"
    p.description.fr.should == "Ces widgets sont utilisables pour votre widgeting quotidien"

    p.authors.should == %w{ baz titi Z }

    p.updated.should == Date.parse("2013-03-15")
  end

  it "should install all items from a package" do
    p = Protopack::Package.find("standard-widgets")
    p.apply_all

    Widget.all.map(&:colour).should == %w{ red blue yellow green black }
  end

  it "should install all items from a package, overwriting existing items, respecting #ordinal property" do
    Widget.new :colour => "blue"
    Widget.new :colour => "green"

    p = Protopack::Package.find("standard-widgets")
    p.apply_all

    Widget.all.map(&:colour).should == %w{ blue green red yellow black }
    Widget.all[0].height.should == 'elephant'
    Widget.all[1].height.should == 'zebra'
    Widget.all[2].height.should == 'tiger'
    Widget.all[3].height.should == 'hyena'
    Widget.all[4].height.should == 'camel'
  end

  it "should install only missing items from a package, not overwriting existing items" do
    Widget.new :colour => "blue", :height => "not specified"
    Widget.new :colour => "green", :height => "not specified"

    p = Protopack::Package.find("standard-widgets")
    p.apply_missing

    Widget.all.map(&:colour).should == %w{ blue green red yellow black}
    Widget.all[0].height.should == "not specified"
    Widget.all[1].height.should == "not specified"
    Widget.all[2].height.should == 'tiger'
    Widget.all[3].height.should == 'hyena'
    Widget.all[4].height.should == 'camel'
  end

end
