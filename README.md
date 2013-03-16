# Protopack

Protopack knows how to load object definitions (prototypes) from packages of yml files and apply
them to your object repository. It's built to work seamslessly with ActiveRecord but doesn't depend
on any component of Rails.

## Installation

Add this line to your application's Gemfile:

    gem 'protopack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install protopack

## Usage

Store package items in a directory structure such as this:

    config
    |- packages
       |- this-package
       |  |- package-config.yml
       |  |- this-first-item.yml
       |  |- this-second-item.yml
       |  |- this-third-item.yml
       |- that-package
          |- package-config.yml
          |- that-first-item.yml
          |- that-second-item.yml
          |- that-third-item.yml

Each "item" file stores attributes of the prototypes you want to be able to create.

Protopack::Package distinguishes between items that already exist, and items that are missing.

In order to add only missing items to your repository, call

    package.apply_missing

In order to apply all package items, overwriting existing items in your repository and adding any
missing items, call

    package.apply_all

Protopack expects your models to implement a class method #existence to provide the interface for
querying and creating objects. The expected interface is the same as that returned by Rails'
ActiveRelation, so it works seamlessly with ActiveRecord.

    exists = YourModel.existence(attributes)

    exists.empty? # => boolean

    exists.create!(attributes)  # => create an instance using the given attributes

    exists.first.update_attributes(attributes)  # => overwrite attributes of an existing instance


### package-config.yml

Each package requires a package-config.yml file, with at least a "name" key. You can add whatever
other keys you like that may be useful to your application for selecting and presenting packages.

Example package-config.yml:

    ---
    name: my-widget-package
    title:
      en: A sample package of prototypes
      fr: Un package exemplaire plain de prototypes
    description:
      en: Widgets to set up the widgeting process. Remember to enscarfle the widget feature if you install this package.
      fr: Machins pour initialiser le processus de machination. Une fois installé, il faut impérativement enscarfler la case machinations.
    prerequisites:
      - my-other-package
    updated: 2013-03-15


### Item files

Protopack::Package looks for item files in the same directory as the package-config.yml file. Item
file names must match the glob pattern "*item*.yml". This pattern allows you give locale-specific
names to items, if l10n is a concern: "widget-item.fr.yml", for example.

Each *-item.yml contains at least three keys: "id", "type" and "attributes". Protopack calls #constantize
on the "type" value in order to get a reference to the target class. The "attributes" are then
passed to your #existence method as described above. If you specify an "ordinal" key, it must be
numeric, and both Package#apply_all and Package#apply_missing will apply items after sorting by #ordinal,
putting nil ordinals last.

You can add other keys that you might find useful for selecting and presenting items, for example, a
"locale" key to show only items in the current user's locale.

Protopack does no pre- or post-processing. Instead, define attributes on your models that will know
what to do, perhaps in conjunction with a :before_save or :after_save handler.

Example item file:

    ---
    id:                 example-widget
    description:        "This is a kind of widget that's good for widgeting"
    locale:             en
    type:               Widgets::PublicWidget
    attributes:
      name:             good-widget
      lang:             en
      size:             42
      next-widget-name: better-widget
      permissions:      widget-admin, widget-user



## Security

Packages are executable code. Don't let end-users provide packages or package items. Protopack allows
package authors call any method on any class.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
